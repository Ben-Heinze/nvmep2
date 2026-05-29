local present = {}

local function create_floating_window(opts)
  opts = opts or {}
  local width = opts.width or math.floor(vim.o.columns * 0.8)
  local height = opts.height or math.floor(vim.o.lines * 0.8)

  -- Calculate the position to center the window
  local col = math.floor((vim.o.columns - width) / 2)
  local row = math.floor((vim.o.columns - height) / 2)

  -- Create a buffer
  local buf = nil
  if vim.api.nvim_buf_is_valid(opts.buf) then
    buf = opts.buf
  else
    buf = vim.api.nvim_create_buf(false, true) -- no file, scratch buffer
  end

  -- Define window configuration
  local win_config = {
    relative = 'editor',
    width = width,
    height = height,
    col = col,
    row = row,
    style = 'minimal',
    border = 'rounded',
  }
end

present.setup = function()
  print('Hellozzz from present.lua!')
end

---@class present.Slides
---@fields slides string[]

--- Takes some lines and parses them
---@param lines string[]: The lines in the buffer
---@return present.Slides
local parse_slides = function(lines)
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

present.start_presentation = function()
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  local parsed = parse_slides(lines)
  local float = create_floating_window()

  vim.api.nvim_buf_set_lines(float.buf, 0, -1, false, parsed.slides[1])
end

vim.print(parse_slides {
  '# Hello',
  'this is something else',
  '# World',
  'this is another thing',
})

-- present.setup()

-- return present
