module Moon
  class Text < RenderContainer
    attr_accessor :color    # Moon::Vector4
    attr_reader   :font     # Moon::Font
    attr_accessor :align    # Symbol [:left, :right, :center]
    attr_reader   :string   # String
    attr_reader   :width
    attr_reader   :height
    attr_accessor :line_height

    def font=(new_font)
      @font = new_font
      refresh_size
    end

    def string=(new_string)
      @string = new_string.to_s
      @lines = @string.split("\n")
      refresh_size
    end

    def initialize(string=nil, font=nil, align=:left)
      @lines = []
      @font = font
      @align = align
      @color = Vector4.new 1.0, 1.0, 1.0, 1.0
      @line_height = 1.2
      super()
      self.string = string
    end

    def set(options)
      self.string = options.fetch :string
      self.align = options.fetch :align, :left
      if fon = options[:font]
        self.font = fon
      end
      self
    end

    def line_height
      @font.size * @line_height
    end

    def render(x=0, y=0, z=0, options={})
      if @font && @string
        @lines.each_with_index do |line, index|
          pos = @position + [x, y, z]

          case @align
          when :left
            # do nothing
          when :right
            pos.x -= @font.calc_bounds(line)[0]
          when :center
            pos.x -= @font.calc_bounds(line)[0] / 2
          end

          font.render(pos.x, pos.y + index * line_height, pos.z,
                      line, @color, options)
        end
      end
      super x, y, z
    end

    def refresh_size
      if @font && @string
        vec2 = Vector2.new(0, 0)
        @lines.each do |line|
          bounds = @font.calc_bounds(line)
          vec2.x = bounds[0] if vec2.x < bounds[0]
          vec2.y = bounds[1] if vec2.y < bounds[1]
          vec2.y += [line_height, bounds[1]].max
          vec2.y += 2 # compensate for outline
          vec2
        end
        @width, @height = *vec2.floor
      else
        @width, @height = 0, 0
      end
    end
  end
end
