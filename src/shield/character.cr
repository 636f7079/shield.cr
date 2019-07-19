module Shield::Character
  extend self

  def offset : Array(Array(Int32))
    [[-12_i32, -18_i32, -24_i32],
     [-39_i32, -56_i32, -62_i32],
     [6_i32, 12_i32, 18_i32],
     [-45_i32, -49_i32],
     [23_i32, 33_i32], [-11_i32, -15_i32],
     [55_i32, 65_i32], [0_i32, 0_i32]]
  end

  def unexpect
    ['\\', '"', '\'', '$', ',', ';', '%', '?']
  end

  def slice_sum(slice : Array(Char))
    (slice.map &.ord).sum
  end

  def hex_bytes(slice, current : Int32)
    case current
    when slice.size
      slice[current].ord + slice[slice.size - 1_i32].ord
    when 0_i32
      slice[current].ord + slice[1_i32].ord
    else
      slice[current].ord + slice[current - 1_i32].ord
    end
  end

  def offset_char(slice, current, odd, even : Int32)
    case slice_sum(slice).odd?
    when true
      if hex_bytes(slice, current).odd?
        skip slice[current] + offset[even].last
      else
        skip slice[current] + offset[odd].first
      end
    when false
      if hex_bytes(slice, current).odd?
        skip slice[current] + offset[even].first
      else
        skip slice[current] + offset[odd].last
      end
    end
  end

  def skip(char : Char)
    return char unless unexpect.includes? char
    skip char - 1_i32 if unexpect.includes? char
  end

  def total(text : String)
    number = text.scan(/[0-9]/).size
    _lower = text.scan(/[a-f]/).size
    _upper = text.scan(/[A-F]/).size
    __all_ = number + _lower + _upper
    [number - 1_i32, _lower - 1_i32,
     _upper - 1_i32,
     text.size - 1_i32 - __all_]
  end

  def user_name(slice : Array(Char))
    slice.each_with_index.map do |char|
      next char.first if char.first.lowercase?
      offset_char(slice, char.last, 6_i32, 6_i32).try do |value|
        next value
      end
    end.join
  end

  def obfuscate(text : String, option : Option)
    text.chars.each_slice(4).map do |slice|
      n, l, u, c = total slice.join
      slice.each_with_index.map do |ch|
        if ch.first.lowercase?
          case [l > 0_i32, u, c, n]
          when [true, -1_i32, c, n]
            l -= 1_i32 ensure u += 1_i32
            covert slice, ch.last,
              :lowerToUpper,
              option.useSymbol
          when [true, u, -1_i32, n]
            l -= 1_i32 ensure c += 1_i32
            covert slice, ch.last,
              :lowerToChars,
              option.useSymbol
          when [true, u, c, -1_i32]
            l -= 1_i32 ensure n += 1_i32
            covert slice, ch.last,
              :lowerToNumber,
              option.useSymbol
          else
            covert slice, ch.last,
              :lowerToRandom,
              option.useSymbol
          end
        elsif ch.first.number?
          case [n > 0_i32, u, c, l]
          when [true, u, c, -1_i32]
            n -= 1_i32 ensure l += 1_i32
            covert slice, ch.last,
              :numberToLower,
              option.useSymbol
          when [true, -1_i32, c, l]
            n -= 1_i32 ensure u += 1_i32
            covert slice, ch.last,
              :numberToUpper,
              option.useSymbol
          when [true, u, -1_i32, l]
            n -= 1_i32 ensure c += 1_i32
            covert slice, ch.last,
              :numberToChars,
              option.useSymbol
          else
            covert slice, ch.last,
              :numberToRandom,
              option.useSymbol
          end
        end
      end.join.reverse
    end.join
  end

  def odd_even(type, symbol : Bool)
    case type
    when :lowerToUpper
      if symbol
        yield 0_i32, 2_i32
      else
        yield 2_i32, 3_i32
      end
    when :lowerToChars
      if symbol
        yield 1_i32, 3_i32
      else
        yield 3_i32, 2_i32
      end
    when :lowerToLower
      if symbol
        yield 2_i32, 0_i32
      else
        yield 3_i32, 2_i32
      end
    when :lowerToNumber
      if symbol
        yield 3_i32, 1_i32
      else
        yield 2_i32, 3_i32
      end
    when :lowerToRandom
      if symbol
        yield 2_i32, 0_i32
      else
        yield 2_i32, 3_i32
      end
    when :numberToUpper
      if symbol
        yield 4_i32, 7_i32
      else
        yield 7_i32, 6_i32
      end
    when :numberToChars
      if symbol
        yield 5_i32, 7_i32
      else
        yield 6_i32, 7_i32
      end
    when :numberToLower
      if symbol
        yield 6_i32, 4_i32
      else
        yield 7_i32, 6_i32
      end
    when :numberToRandom
      if symbol
        yield 6_i32, 6_i32
      else
        yield 6_i32, 7_i32
      end
    else
      yield 7_i32, 7_i32
    end
  end

  def covert(slice, current, type, symbol : Bool)
    odd_even(type, symbol) do |odd, even|
      offset_char slice, current, odd, even
    end
  end
end
