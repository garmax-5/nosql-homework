package ratelimiter;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.time.Instant;
import java.util.Arrays;
import java.util.Collections;
import java.util.UUID;

import redis.clients.jedis.Jedis;
import redis.clients.jedis.JedisPool;

public class RateLimiter {

  private final Jedis redis;
  private final String label;
  private final long maxRequestCount;
  private final long timeWindowSeconds;

  private final String SCRIPT = LuaScriptLoader.load("scripts/rate_limiter.lua");

  public RateLimiter(Jedis redis, String label, long maxRequestCount, long timeWindowSeconds) {
    this.redis = redis;
    this.label = label;
    this.maxRequestCount = maxRequestCount;
    this.timeWindowSeconds = timeWindowSeconds;
  }

  /**
   Замечание по архитектуре:
   Скрипт Lua загружается напрямую через LuaScriptLoader
   Не сделал отдельный интерфейс ScriptLoader, потому что:
     - на данный момент нет разных вариантов загрузки скрипта
     - абстракция через интерфейс добавила бы лишний уровень сложности без практической пользы (пришлось бы переписывать архитектуру)

   В будущем, если появятся разные источники Lua скриптов, можно будет вынести ScriptLoader
   в отдельный интерфейс и внедрять его через конструктор, путь к файлу можно вынести в отдельный конфигурационный файл
   (В данный момент в коде нарушены принципы SOLID).
   */
  public boolean pass() {
    long timeNow = Instant.now().toEpochMilli();
    String requestId = timeNow + ":" + UUID.randomUUID();

    Object result = redis.eval(
        SCRIPT,
        Collections.singletonList(label),
        Arrays.asList(
            String.valueOf(timeNow),
            String.valueOf(timeWindowSeconds),
            String.valueOf(maxRequestCount),
            requestId
        )
    );

    return Long.valueOf(1L).equals(result);
  }

  public static void main(String[] args) {
    JedisPool pool = new JedisPool("localhost", 6379);

    try (Jedis redis = pool.getResource()) {
      RateLimiter rateLimiter = new RateLimiter(redis, "pr_rate", 1, 1);

      BufferedReader br = new BufferedReader(new InputStreamReader(System.in));
      long prev = Instant.now().toEpochMilli();
      long now;

      while (true) {
        try {
          String s = br.readLine();
          if (s == null || s.equals("q")) {
            return;
          }
          boolean passed = rateLimiter.pass();

          now = Instant.now().toEpochMilli();
          if (passed) {
            System.out.printf("%d ms: %s", now - prev, "passed");
            prev = now;
          } else {
            System.out.printf("%d ms: %s", now - prev, "limited");
          }
        } catch (IOException e) {
          e.printStackTrace();
        }
      }

    }
  }
}
