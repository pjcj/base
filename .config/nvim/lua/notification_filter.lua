-- notification_filter.lua
-- Filters and rate-limits notifications to prevent spam

local M = {}

-- Track last notification times by message pattern
local last_notifications = {}

-- Configuration
local config = {
  -- Rate limiting: minimum seconds between similar notifications
  rate_limits = {
    quota = 60, -- Quota exceeded messages
    default = 30, -- Other filtered messages
  },

  -- Message transformations
  transforms = {
    {
      pattern = "Gemini returns error on streaming:.*You exceeded your current quota.*",
      replacement = "Gemini quota exceeded",
      category = "quota",
    },
  },
}

-- Get current time in seconds
local function get_time()
  return vim.uv.hrtime() / 1e9
end

-- Transform message using configured patterns
local function transform_message(msg)
  local transformed = msg
  local category = "default"

  for _, transform in ipairs(config.transforms) do
    local new_msg = transformed:gsub(transform.pattern, transform.replacement)
    if new_msg ~= transformed then
      transformed = new_msg
      category = transform.category
    end
  end

  -- Clean up extra whitespace and punctuation
  transformed = transformed:gsub("%s+", " "):gsub("^%s+", ""):gsub("%s+$", "")
  transformed = transformed:gsub("%.%s*%.+", ".")

  return transformed, category
end

-- Check if notification should be rate limited
local function should_rate_limit(msg, category)
  local now = get_time()
  local rate_limit = config.rate_limits[category] or config.rate_limits.default
  local key = category .. ":" .. msg

  local last_time = last_notifications[key]
  if not last_time then
    last_notifications[key] = now
    return false
  end

  if now - last_time >= rate_limit then
    last_notifications[key] = now
    return false
  end

  return true
end

-- Store original vim.notify
local original_notify = vim.notify

-- Custom notify function
local function filtered_notify(msg, level, opts)
  if type(msg) ~= "string" then
    return original_notify(msg, level, opts)
  end

  -- Transform the message
  local transformed_msg, category = transform_message(msg)

  -- Skip empty messages
  if transformed_msg == "" then
    return
  end

  -- Check rate limiting
  if should_rate_limit(transformed_msg, category) then
    return
  end

  -- Call original notify with transformed message
  return original_notify(transformed_msg, level, opts)
end

-- Setup function to install the filter
function M.setup(user_config)
  -- Merge user config if provided
  if user_config then
    config = vim.tbl_deep_extend("force", config, user_config)
  end

  -- Replace vim.notify with our filtered version
  vim.notify = filtered_notify
end

-- Function to restore original notify (for testing/debugging)
function M.restore()
  vim.notify = original_notify
end

-- Function to clear rate limiting history
function M.clear_history()
  last_notifications = {}
end

-- Export for debugging
function M.get_history()
  return vim.deepcopy(last_notifications)
end

return M
