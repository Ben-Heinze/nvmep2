local present = require('user.present')

describe('user.present', function()
  describe('parse_slides', function()
    it('returns a single slide when no separators exist', function()
      local slides = present.parse_slides({ 'a', 'b', 'c' })
      assert.are.same({ { 'a', 'b', 'c' } }, slides.slides)
    end)

    it('splits slides on lines starting with # and keeps separator line', function()
      local slides = present.parse_slides({
        '# Title',
        'one',
        'two',
        '# Next',
        'three',
      })

      assert.are.same({
        { '# Title', 'one', 'two' },
        { '# Next', 'three' },
      }, slides.slides)
    end)

    it('creates an empty first slide if input starts with a separator', function()
      local slides = present.parse_slides({
        '# One',
        'a',
        '# Two',
        'b',
      })

      assert.are.same({
        { '# One', 'a' },
        { '# Two', 'b' },
      }, slides.slides)
    end)
  end)
end)

