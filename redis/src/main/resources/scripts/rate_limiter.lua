local label = KEYS[1]
local timeNow = tonumber(ARGV[1])
local timeWindowSeconds = tonumber(ARGV[2])
local maxRequestCount = tonumber(ARGV[3])
local requestId = ARGV[4]

local windowStart = timeNow - timeWindowSeconds * 1000

redis.call('ZREMRANGEBYSCORE', label, 0, windowStart)

local currentCount = redis.call('ZCOUNT', label, windowStart, timeNow)

if currentCount >= maxRequestCount then
    return 0
end

redis.call('ZADD', label, timeNow, requestId)
redis.call('EXPIRE', label, timeWindowSeconds)

return 1