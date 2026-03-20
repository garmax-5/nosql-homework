package ratelimiter;

import java.io.InputStream;
import java.nio.charset.StandardCharsets;

public final class LuaScriptLoader {

  public static String load(String path) {
    try (InputStream is = LuaScriptLoader.class
        .getClassLoader()
        .getResourceAsStream(path)) {

      if (is == null) {
        throw new IllegalArgumentException("Lua script not found: " + path);
      }

      return new String(is.readAllBytes(), StandardCharsets.UTF_8);

    } catch (Exception e) {
      throw new RuntimeException("Failed to load Lua script: " + path, e);
    }
  }
}