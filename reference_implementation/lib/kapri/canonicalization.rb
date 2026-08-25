require "json"

module Kapri
  # RFC 8785 - JSON Canonicalization Scheme (JCS).
  #
  # SC0 SS3.8 requires the canonical representation of a Package component
  # wherever a hash or signature is calculated over it. S1 SS3.2.14 and
  # S4 SS3.2.7 both normatively require RFC 8785 for the Package Manifest /
  # KAP-KDM signature. This reference implementation applies the same
  # canonicalization to every JSON document it writes to disk (Packing
  # List, Composition, Manifest, KDM), so that a document's on-disk bytes
  # are always exactly the bytes any hash over it was computed from.
  #
  # Covers: recursive object/array serialization, object key ordering by
  # UTF-16 code unit (not code point) order, RFC 8785 SS3.2.2.2 string
  # escaping, RFC 8785 SS3.2.2.3 ECMAScript-style number formatting. Not a
  # complete implementation of every IEEE-754 edge case from RFC 8785
  # Appendix B. The current normative KAPRI schemas use integers, strings,
  # booleans and null, and do not admit floating-point properties.
  module Canonicalization
    module_function

    def canonicalize(json_string_or_value)
      value = json_string_or_value.is_a?(String) ? JSON.parse(json_string_or_value) : json_string_or_value
      serialize(value)
    end

    def serialize(value)
      case value
      when Hash
        serialize_object(value)
      when Array
        serialize_array(value)
      when String
        serialize_string(value)
      when Integer
        value.to_s
      when Float
        serialize_number(value)
      when true, false
        value.to_s
      when nil
        "null"
      else
        raise ArgumentError, "Nicht serialisierbarer Typ für JCS: #{value.class}"
      end
    end

    def serialize_object(hash)
      sorted_keys = hash.keys.sort_by { |k| utf16be_bytes(k.to_s) }
      body = sorted_keys.map { |k| "#{serialize_string(k.to_s)}:#{serialize(hash[k])}" }.join(",")
      "{#{body}}"
    end

    def serialize_array(array)
      "[#{array.map { |v| serialize(v) }.join(',')}]"
    end

    # RFC 8785 SS3.2.2.2: predefined escapes for \b \t \n \f \r, all other
    # ASCII control characters (< 0x20) as \u00xx (lowercase).
    ESCAPES = {
      "\x08" => '\b',
      "\x09" => '\t',
      "\x0A" => '\n',
      "\x0C" => '\f',
      "\x0D" => '\r',
      '"'    => '\"',
      "\\"   => '\\\\'
    }.freeze

    def serialize_string(str)
      out = +'"'
      str.each_char do |ch|
        if ESCAPES.key?(ch)
          out << ESCAPES[ch]
        elsif ch.ord < 0x20
          out << format('\u%04x', ch.ord)
        else
          out << ch
        end
      end
      out << '"'
    end

    def serialize_number(float)
      raise ArgumentError, "NaN/Infinity sind nicht JSON-kanonisierbar" if float.nan? || float.infinite?
      return "0" if float.zero?

      sign = float.negative? ? "-" : ""
      digits, n = shortest_round_trip_digits(float.abs)
      k = digits.length

      body =
        if k <= n && n <= 21
          digits + ("0" * (n - k))
        elsif n.positive? && n <= 21
          "#{digits[0...n]}.#{digits[n..]}"
        elsif n <= 0 && n > -6
          "0.#{'0' * -n}#{digits}"
        else
          exponent = n - 1
          mantissa = k == 1 ? digits : "#{digits[0]}.#{digits[1..]}"
          "#{mantissa}e#{exponent.positive? ? '+' : ''}#{exponent}"
        end

      sign + body
    end

    # Returns [significant digits without leading/trailing zeros, n], such
    # that value == 0.<digits> * 10**n (n = position of the decimal point,
    # counted from the first significant digit). Uses Ruby's Float#to_s as
    # the digit source - like ECMAScript, Ruby chooses the shortest
    # round-trip decimal representation; only the notation differs (hence
    # the reformatting in serialize_number).
    def shortest_round_trip_digits(positive_float)
      ruby_repr = positive_float.to_s
      mantissa_part, exponent_part = ruby_repr.split("e")
      exponent = exponent_part.to_i

      int_part, frac_part = mantissa_part.split(".")
      raw_digits = int_part + frac_part
      point_pos = int_part.length + exponent

      leading_zeros = raw_digits[/\A0+/]&.length || 0
      raw_digits = raw_digits[leading_zeros..]
      point_pos -= leading_zeros

      raw_digits = raw_digits.sub(/0+\z/, "")
      raw_digits = "0" if raw_digits.empty?

      [raw_digits, point_pos]
    end
    private_class_method :shortest_round_trip_digits

    def utf16be_bytes(str)
      str.encode(Encoding::UTF_16BE).b
    end
    private_class_method :utf16be_bytes
  end
end
