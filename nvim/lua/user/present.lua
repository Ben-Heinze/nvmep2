local M = {}

local function create_floating_window(opts)
  opts = opts or {}
  local width = opts.width or math.floor(vim.o.columns * 0.8)
  local height = opts.height or math.floor(vim.o.lines * 0.8)

  local col = math.floor((vim.o.columns - width) / 2)
  local row = math.floor((vim.o.lines - height) / 2)

  local buf
  if opts.buf and vim.api.nvim_buf_is_valid(opts.buf) then
    buf = opts.buf
  else
    buf = vim.api.nvim_create_buf(false, true)
  end

  local win = vim.api.nvim_open_win(buf, true, {
    relative = 'editor',
    width = width,
    height = height,
    col = col,
    row = row,
    style = 'minimal',
    border = 'rounded',
  })

  return { buf = buf, win = win }
end

---@class present.Slides
---@fields slides string[]

--- Takes some lines and parses them
---@param lines string[]: The lines in the buffer
---@return present.Slides
M.parse_slides = function(lines)
  local slides = { slides = {} }
  local current_slide = {}
  local separator = '^#'
  for _, line in ipairs(lines) do
    if line:find(separator) then
      if #current_slide > 0 then
        table.insert(slides.slides, current_slide)
      end
      current_slide = {}
    end
    table.insert(current_slide, line)
  end
  table.insert(slides.slides, current_slide)
  return slides
end

M.start_presentation = function()
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  local parsed = M.parse_slides(lines)
  local float = create_floating_window()

  vim.api.nvim_buf_set_lines(float.buf, 0, -1, false, parsed.slides[1])
end

return M
