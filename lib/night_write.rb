require 'pry'

class NightWrite
  def self.to_braille(text)
    if text
      chars = text.split('')
      top, mid, bot = get_lines(chars)
      assemble_braille_lines(top, mid, bot)
    end
  end

  def self.get_lines(chars)
    top, mid, bot = '', '', ''
    chars.each do |char|
      next if char == "\n"
      t, m, b = character_to_braille(char)
      top += t
      mid += m
      bot += b
    end
    return top, mid, bot
  end

  def self.character_to_braille(character)
    top = to_braille_top_line(character)
    mid = to_braille_mid_line(character)
    bot = to_braille_bot_line(character)
    return top, mid, bot
  end

  def self.to_braille_top_line(character)
    case character
    when 'c', 'd', 'f', 'g', 'm',
         'n', 'p', 'q', 'x', 'y'
      '00'
    when ' '
      '..'
    when 'a', 'b', 'e', 'h', 'k',
         'l', 'o', 'r', 'u', 'v',
         'z'
      '0.'
    when 'i', 'j', 's', 't', 'w'
      '.0'
    when 'A'..'Z'
      '..' + to_braille_top_line(character.downcase)
    else
      fail ArgumentError
    end
  end

  def self.to_braille_mid_line(character)
    case character
    when 'g', 'h', 'j', 'q', 'r',
         't', 'w'
      '00'
    when 'a', 'c', 'k', 'm',
         'x', ' '
      '..'
    when 'b', 'f', 'i', 'l', 'p',
         's', 'v'
      '0.'
    when 'd', 'e', 'n', 'o', 'y',
         'z'
      '.0'
    when 'A'..'Z'
      '..' + to_braille_mid_line(character.downcase)
    else
      fail ArgumentError
    end
  end

  def self.to_braille_bot_line(character)
    case character
    when 'u', 'v', 'x', 'y', 'z'
      '00'
    when 'a', 'b', 'c', 'd', 'e',
         'e', 'f', 'g', 'h', 'i',
         'j', ' '
      '..'
    when 'k', 'l', 'm', 'n', 'o',
         'p', 'q', 'r', 's', 't'
      '0.'
    when 'w'
      '.0'
    when 'A'..'Z'
      '.0' + to_braille_bot_line(character.downcase)
    else
      fail ArgumentError
    end
  end

  def self.assemble_braille_lines(top, mid, bot)
    if too_wide?(top)
      next_top, next_mid, next_bot = wrap_to_next_line(top, mid, bot)
      format_braille(top, mid, bot) +
        "\n" + format_braille(next_top, next_mid, next_bot)
    else
      format_braille(top, mid, bot)
    end
  end

  def self.too_wide?(line)
    line.length > 80
  end

  def self.wrap_to_next_line(top, mid, bot)
    next_top = top.slice!(80..-1)
    next_mid = mid.slice!(80..-1)
    next_bot = bot.slice!(80..-1)
    return next_top, next_mid, next_bot
  end

  def self.format_braille(top, mid, bot)
    top + "\n" + mid + "\n" + bot
  end

  def self.import(filename)
    File.read(filename)
  end

  def self.export(filename, data)
    File.write(filename, data)
  end
end

if $PROGRAM_NAME == __FILE__ # if I'm running this file
  input_file = ARGV[0]
  output_file = ARGV[1]

  text = NightWrite.import(input_file)
  braille = NightWrite.to_braille(text)
  NightWrite.export(output_file, braille.strip)

  puts "Created '#{output_file}' containing #{braille.chars.count} characters"
end
