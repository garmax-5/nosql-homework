-- Решение заданий по ClickHouse

-- 1. Создание таблицы
CREATE TABLE IF NOT EXISTS server_logs
(
    timestamp        DateTime,
    user_id          UInt32,
    endpoint         LowCardinality(String),
    response_time_ms UInt32,
    status_code      UInt16
) ENGINE = MergeTree()
      PARTITION BY toYYYYMM(timestamp)
      ORDER BY (timestamp, endpoint)
      TTL timestamp + INTERVAL 60 DAY;

-- 2. Загрузка данных из CSV
-- cat server_logs.csv | clickhouse-client --query="INSERT INTO server_logs FORMAT CSVWithNames"

-- 3. Запрос: Топ-5 самых медленных endpoint'ов (по среднему времени ответа)
--EXPLAIN indexes = 1
select
    endpoint,
    avg(response_time_ms) as avg_response_time_ms
from server_logs
group by endpoint
order by avg_response_time_ms desc
limit 5;

-- 4. Запрос: Количество запросов по часам за весь период в логах
select
    toHour(timestamp) as hour_timestamp,
    count(timestamp)  as count_response
from server_logs
group by hour_timestamp
order by hour_timestamp;

-- 5. Запрос: Процент ошибок (status_code >= 400) для каждого endpoint'а
select
    endpoint,
    countIf(status_code >= 400) * 100.0 / count(status_code) as error_percent
from server_logs
group by endpoint