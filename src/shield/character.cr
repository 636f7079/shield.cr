module Shield::Character
  extend self

  def offset : NamedTuple
    {lowerToUpper:  [-12_i32, -18_i32, -24_i32],
     lowerToChar:   [-39_i32, -56_i32, -62_i32],
     lowerToLower:  [6_i32, 12_i32, 18_i32],
     lowerToNumber: [-45_i32, -49_i32],
     numberToUpper: [23_i32, 33_i32],
     numberToChar:  [-11_i32, -15_i32],
     numberToLower: [55_i32, 65_i32],
     upperToChar:   [-38_i32, -31_i32],
     upperToNumber: [-23_i32, -19_i32],
     default:       [0_i32, 0_i32, 0_i32, 0_i32]}
  end

  def unexpect
    ['\\', '"', '\'', '$', ',', ';', '%', '?']
  end

  def valid_range
    {default: [0..0],
     char:    [33..47, 58..63],
     lower:   [103..122],
     upper:   [71..90],
     number:  [48..57]}
  end

  def slice_sum(slice : Array(Char))
    (slice.map &.ord).sum
  end

  def type_to_range(type : Symbol)
    case type
    when :lowerToUpper
      yield valid_range[:upper]
    when :lowerToChar
      yield valid_range[:char]
    when :lowerToLower
      yield valid_range[:lower]
    when :lowerToNumber
      yield valid_range[:number]
    when :numberToUpper
      yield valid_range[:upper]
    when :numberToChar
      yield valid_range[:char]
    when :numberToLower
      yield valid_range[:lower]
    when :upperToChar
      yield valid_range[:char]
    when :upperToNumber
      yield valid_range[:number]
    else
      yield valid_range[:default]
    end
  end

  def strict_add(type, current, add : Int32)
    type_to_range type do |range|
      arr_range = range.map(&.to_a).flatten
      total_ord = current.ord + add
      ord = total_ord.to_s[-1].to_i
      return total_ord.chr if type == :default
      range.each do |_range|
        if _range.includes? total_ord
          return total_ord.chr
        end
      end
      if total_ord > arr_range.last
        (arr_range.last - ord).chr
      elsif total_ord < arr_range.first
        (arr_range.first + ord).chr
      end
    end
  end

  def hash_bytes(slice, current : Int32)
    case current
    when slice.size
      slice[current].ord + slice[slice.size - 1_i32].ord
    when 0_i32
      slice[current].ord + slice[1_i32].ord
    else
      slice[current].ord + slice[current - 1_i32].ord
    end
  end

  def offset_char(slice, current, odd, even : Symbol)
    case slice_sum(slice).odd?
    when true
      if hash_bytes(slice, current).odd?
        skip slice[current] + offset[even].last
      else
        skip slice[current] + offset[odd].first
      end
    when false
      if hash_bytes(slice, current).odd?
        skip slice[current] + offset[even].first
      else
        skip slice[current] + offset[odd].last
      end
    end
  end

  def strict_offset_char(slice, current, type : Symbol)
    case slice_sum(slice).odd?
    when true
      if hash_bytes(slice, current).odd?
        strict_add(type, slice[current],
          offset[type].last).try do |data|
          skip data
        end
      else
        strict_add(type, slice[current],
          offset[type].first).try do |data|
          skip data
        end
      end
    when false
      if hash_bytes(slice, current).odd?
        strict_add(type, slice[current],
          offset[type].first).try do |data|
          skip data
        end
      else
        strict_add(type, slice[current],
          offset[type].last).try do |data|
          skip data
        end
      end
    end
  end

  def skip(char : Char)
    return char unless unexpect.includes? char
    skip char - 1_i32 if unexpect.includes? char
  end

  def total(text : String, space = 1_i32)
    number = text.scan(/[0-9]/).size
    _lower = text.scan(/[a-z]/).size
    _upper = text.scan(/[A-Z]/).size
    __all_ = number + _lower + _upper
    [number - space, _lower - space,
     _upper - space,
     text.size - space - __all_]
  end

  def user_name(slice : Array(Char)) : String
    slice.each_with_index.map do |char|
      next char.first if char.first.lowercase?
      offset = offset_char slice, char.last,
        :numberToLower, :numberToLower
      offset.try { |value| next value }
    end.join
  end

  def strict_obfuscate(text : String, option : Option)
    return text unless option.useSymbol
    _total = total text, option.length / 4_i32
    number, lower, upper, char = _total
    unless number == -5_i32 || char == -5_i32
      return text unless upper == -5_i32
    end
    strict_obfuscate String.build { |io|
      io << text[0_i32..3_i32]
      io << final_fill text[4_i32..], option
    }, option
  end

  def final_fill(text : String, option : Option)
    text.chars.each_slice(4).map do |slice|
      n, l, u, c = total slice.join
      slice.each_with_index.map do |ch|
        if ch.first.lowercase?
          case [l > 0_i32, u, c, n]
          when [true, -1_i32, c, n]
            l -= 2_i32 ensure u += 1_i32
            strict_offset_char slice,
              ch.last, :lowerToUpper
          when [true, u, -1_i32, n]
            l -= 2_i32 ensure c += 1_i32
            strict_offset_char slice,
              ch.last, :lowerToChar
          else
            ch.first
          end
        elsif ch.first.uppercase?
          case [u > 0_i32, l, c, n]
          when [true, l, -1_i32, n]
            u -= 2_i32 ensure c += 1_i32
            strict_offset_char slice,
              ch.last, :upperToChar
          when [true, l, c, -1_i32]
            u -= 2_i32 ensure n += 1_i32
            strict_offset_char slice,
              ch.last, :upperToNumber
          else
            ch.first
          end
        elsif ch.first.number?
          case [n > 0_i32, u, c, l]
          when [true, -1_i32, c, l]
            n -= 2_i32 ensure u += 1_i32
            strict_offset_char slice,
              ch.last, :numberToUpper
          when [true, u, -1_i32, l]
            n -= 2_i32 ensure c += 1_i32
            strict_offset_char slice,
              ch.last, :numberToChar
          else
            ch.first
          end
        end
      end.join
    end.join
  end

  def hash_obfuscate(text : String, option : Option)
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
              :lowerToChar,
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
              :numberToChar,
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

  def odd_even(type : Symbol, symbol : Bool)
    case type
    when :lowerToUpper
      if symbol
        yield :lowerToUpper, :lowerToLower
      else
        yield :lowerToLower, :lowerToNumber
      end
    when :lowerToChar
      if symbol
        yield :lowerToChar, :lowerToNumber
      else
        yield :lowerToNumber, :lowerToLower
      end
    when :lowerToLower
      if symbol
        yield :lowerToLower, :lowerToUpper
      else
        yield :lowerToNumber, :lowerToLower
      end
    when :lowerToNumber
      if symbol
        yield :lowerToNumber, :lowerToChar
      else
        yield :lowerToLower, :lowerToNumber
      end
    when :lowerToRandom
      if symbol
        yield :lowerToLower, :lowerToUpper
      else
        yield :lowerToLower, :lowerToNumber
      end
    when :numberToUpper
      if symbol
        yield :numberToUpper, :default
      else
        yield :default, :numberToLower
      end
    when :numberToChar
      if symbol
        yield :numberToChar, :default
      else
        yield :numberToLower, :default
      end
    when :numberToLower
      if symbol
        yield :numberToLower, :numberToUpper
      else
        yield :default, :numberToLower
      end
    when :numberToRandom
      if symbol
        yield :numberToLower, :numberToLower
      else
        yield :numberToLower, :default
      end
    else
      yield :default, :default
    end
  end

  def covert(slice, current, type, symbol : Bool)
    odd_even(type, symbol) do |odd, even|
      offset_char slice, current, odd, even
    end
  end
end
