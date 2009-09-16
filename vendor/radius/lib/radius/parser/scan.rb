
# line 1 "scan.rl"

# line 83 "scan.rl"


module Radius
  class Scanner
    def self.operate(prefix, data)
      buf = ""
      csel = ""
      @prematch = ''
      @starttag = nil
      @attrs = {}
      @flavor = :tasteless
      @cursor = 0
      @tagstart = 0
      @nodes = ['']
      remainder = data.dup

      until remainder.length == 0
        p = perform_parse(prefix, remainder)
        remainder = remainder[p..-1]
      end

      return @nodes
    end
    
    private
    def self.perform_parse(prefix, data)
      stack = []
      p = 0
      ts = 0
      te = 0
      act = 0
      eof = data.length
      
      @prefix = prefix
      
# line 41 "scan.rb"
class << self
	attr_accessor :_parser_actions
	private :_parser_actions, :_parser_actions=
end
self._parser_actions = [
	0, 1, 0, 1, 1, 1, 2, 1, 
	3, 1, 4, 1, 5, 1, 6, 1, 
	7, 1, 8, 1, 9, 1, 13, 1, 
	14, 1, 18, 1, 20, 1, 21, 1, 
	22, 2, 4, 5, 2, 5, 6, 2, 
	8, 4, 2, 8, 9, 2, 9, 8, 
	2, 10, 19, 2, 11, 19, 2, 12, 
	19, 2, 15, 16, 2, 15, 17, 3, 
	4, 5, 6, 3, 8, 4, 5, 3, 
	15, 5, 16, 4, 8, 4, 5, 6, 
	4, 15, 4, 5, 16, 5, 15, 8, 
	4, 5, 16
]

class << self
	attr_accessor :_parser_key_offsets
	private :_parser_key_offsets, :_parser_key_offsets=
end
self._parser_key_offsets = [
	0, 0, 11, 21, 34, 47, 61, 65, 
	70, 72, 74, 87, 100, 101, 103, 118, 
	133, 149, 155, 161, 176, 179, 182, 185, 
	200, 202, 204, 219, 235, 241, 247, 250, 
	253, 269, 285, 302, 309, 315, 331, 335, 
	351, 366, 369, 371, 381, 392, 402, 416, 
	420, 420, 421, 430, 430, 430, 432, 434, 
	437, 440, 442, 444
]

class << self
	attr_accessor :_parser_trans_keys
	private :_parser_trans_keys, :_parser_trans_keys=
end
self._parser_trans_keys = [
	58, 63, 95, 45, 46, 48, 57, 65, 
	90, 97, 122, 63, 95, 45, 46, 48, 
	58, 65, 90, 97, 122, 32, 47, 62, 
	63, 95, 9, 13, 45, 58, 65, 90, 
	97, 122, 32, 47, 62, 63, 95, 9, 
	13, 45, 58, 65, 90, 97, 122, 32, 
	61, 63, 95, 9, 13, 45, 46, 48, 
	58, 65, 90, 97, 122, 32, 61, 9, 
	13, 32, 34, 39, 9, 13, 34, 92, 
	34, 92, 32, 47, 62, 63, 95, 9, 
	13, 45, 58, 65, 90, 97, 122, 32, 
	47, 62, 63, 95, 9, 13, 45, 58, 
	65, 90, 97, 122, 62, 34, 92, 32, 
	34, 47, 62, 63, 92, 95, 9, 13, 
	45, 58, 65, 90, 97, 122, 32, 34, 
	47, 62, 63, 92, 95, 9, 13, 45, 
	58, 65, 90, 97, 122, 32, 34, 61, 
	63, 92, 95, 9, 13, 45, 46, 48, 
	58, 65, 90, 97, 122, 32, 34, 61, 
	92, 9, 13, 32, 34, 39, 92, 9, 
	13, 32, 34, 47, 62, 63, 92, 95, 
	9, 13, 45, 58, 65, 90, 97, 122, 
	34, 62, 92, 34, 39, 92, 34, 39, 
	92, 32, 39, 47, 62, 63, 92, 95, 
	9, 13, 45, 58, 65, 90, 97, 122, 
	39, 92, 39, 92, 32, 39, 47, 62, 
	63, 92, 95, 9, 13, 45, 58, 65, 
	90, 97, 122, 32, 39, 61, 63, 92, 
	95, 9, 13, 45, 46, 48, 58, 65, 
	90, 97, 122, 32, 39, 61, 92, 9, 
	13, 32, 34, 39, 92, 9, 13, 34, 
	39, 92, 34, 39, 92, 32, 34, 39, 
	47, 62, 63, 92, 95, 9, 13, 45, 
	58, 65, 90, 97, 122, 32, 34, 39, 
	47, 62, 63, 92, 95, 9, 13, 45, 
	58, 65, 90, 97, 122, 32, 34, 39, 
	61, 63, 92, 95, 9, 13, 45, 46, 
	48, 58, 65, 90, 97, 122, 32, 34, 
	39, 61, 92, 9, 13, 32, 34, 39, 
	92, 9, 13, 32, 34, 39, 47, 62, 
	63, 92, 95, 9, 13, 45, 58, 65, 
	90, 97, 122, 34, 39, 62, 92, 32, 
	34, 39, 47, 62, 63, 92, 95, 9, 
	13, 45, 58, 65, 90, 97, 122, 32, 
	39, 47, 62, 63, 92, 95, 9, 13, 
	45, 58, 65, 90, 97, 122, 39, 62, 
	92, 39, 92, 63, 95, 45, 46, 48, 
	57, 65, 90, 97, 122, 58, 63, 95, 
	45, 46, 48, 57, 65, 90, 97, 122, 
	63, 95, 45, 46, 48, 58, 65, 90, 
	97, 122, 32, 62, 63, 95, 9, 13, 
	45, 46, 48, 58, 65, 90, 97, 122, 
	32, 62, 9, 13, 60, 47, 63, 95, 
	45, 57, 65, 90, 97, 122, 34, 92, 
	34, 92, 34, 39, 92, 34, 39, 92, 
	39, 92, 39, 92, 0
]

class << self
	attr_accessor :_parser_single_lengths
	private :_parser_single_lengths, :_parser_single_lengths=
end
self._parser_single_lengths = [
	0, 3, 2, 5, 5, 4, 2, 3, 
	2, 2, 5, 5, 1, 2, 7, 7, 
	6, 4, 4, 7, 3, 3, 3, 7, 
	2, 2, 7, 6, 4, 4, 3, 3, 
	8, 8, 7, 5, 4, 8, 4, 8, 
	7, 3, 2, 2, 3, 2, 4, 2, 
	0, 1, 3, 0, 0, 2, 2, 3, 
	3, 2, 2, 0
]

class << self
	attr_accessor :_parser_range_lengths
	private :_parser_range_lengths, :_parser_range_lengths=
end
self._parser_range_lengths = [
	0, 4, 4, 4, 4, 5, 1, 1, 
	0, 0, 4, 4, 0, 0, 4, 4, 
	5, 1, 1, 4, 0, 0, 0, 4, 
	0, 0, 4, 5, 1, 1, 0, 0, 
	4, 4, 5, 1, 1, 4, 0, 4, 
	4, 0, 0, 4, 4, 4, 5, 1, 
	0, 0, 3, 0, 0, 0, 0, 0, 
	0, 0, 0, 0
]

class << self
	attr_accessor :_parser_index_offsets
	private :_parser_index_offsets, :_parser_index_offsets=
end
self._parser_index_offsets = [
	0, 0, 8, 15, 25, 35, 45, 49, 
	54, 57, 60, 70, 80, 82, 85, 97, 
	109, 121, 127, 133, 145, 149, 153, 157, 
	169, 172, 175, 187, 199, 205, 211, 215, 
	219, 232, 245, 258, 265, 271, 284, 289, 
	302, 314, 318, 321, 328, 336, 343, 353, 
	357, 358, 360, 367, 368, 369, 372, 375, 
	379, 383, 386, 389
]

class << self
	attr_accessor :_parser_indicies
	private :_parser_indicies, :_parser_indicies=
end
self._parser_indicies = [
	2, 1, 1, 1, 1, 1, 1, 0, 
	3, 3, 3, 3, 3, 3, 0, 4, 
	6, 7, 5, 5, 4, 5, 5, 5, 
	0, 8, 10, 11, 9, 9, 8, 9, 
	9, 9, 0, 13, 15, 14, 14, 13, 
	14, 14, 14, 14, 12, 16, 17, 16, 
	12, 17, 18, 19, 17, 12, 21, 22, 
	20, 24, 25, 23, 26, 28, 29, 27, 
	27, 26, 27, 27, 27, 12, 30, 32, 
	33, 31, 31, 30, 31, 31, 31, 12, 
	34, 12, 35, 25, 23, 36, 24, 38, 
	39, 37, 25, 37, 36, 37, 37, 37, 
	23, 40, 24, 42, 43, 41, 25, 41, 
	40, 41, 41, 41, 23, 44, 24, 46, 
	45, 25, 45, 44, 45, 45, 45, 45, 
	23, 47, 24, 48, 25, 47, 23, 48, 
	49, 50, 25, 48, 23, 51, 21, 53, 
	54, 52, 22, 52, 51, 52, 52, 52, 
	20, 24, 55, 25, 23, 57, 58, 59, 
	56, 61, 35, 62, 60, 64, 24, 66, 
	67, 65, 68, 65, 64, 65, 65, 65, 
	63, 24, 68, 63, 61, 68, 63, 69, 
	24, 71, 72, 70, 68, 70, 69, 70, 
	70, 70, 63, 73, 24, 75, 74, 68, 
	74, 73, 74, 74, 74, 74, 63, 76, 
	24, 77, 68, 76, 63, 77, 78, 79, 
	68, 77, 63, 80, 58, 59, 56, 81, 
	81, 62, 60, 82, 61, 35, 84, 85, 
	83, 62, 83, 82, 83, 83, 83, 60, 
	86, 61, 35, 88, 89, 87, 62, 87, 
	86, 87, 87, 87, 60, 90, 61, 35, 
	92, 91, 62, 91, 90, 91, 91, 91, 
	91, 60, 93, 61, 35, 94, 62, 93, 
	60, 94, 95, 96, 62, 94, 60, 97, 
	80, 58, 99, 100, 98, 59, 98, 97, 
	98, 98, 98, 56, 61, 35, 101, 62, 
	60, 97, 57, 58, 99, 100, 98, 59, 
	98, 97, 98, 98, 98, 56, 103, 21, 
	105, 106, 104, 107, 104, 103, 104, 104, 
	104, 102, 24, 108, 68, 63, 21, 107, 
	102, 109, 109, 109, 109, 109, 109, 0, 
	111, 110, 110, 110, 110, 110, 110, 0, 
	112, 112, 112, 112, 112, 112, 0, 113, 
	115, 114, 114, 113, 114, 114, 114, 114, 
	0, 116, 117, 116, 0, 118, 120, 119, 
	123, 122, 122, 122, 122, 122, 121, 124, 
	125, 24, 25, 23, 24, 25, 23, 61, 
	35, 62, 60, 61, 35, 62, 60, 24, 
	68, 63, 24, 68, 63, 126, 0
]

class << self
	attr_accessor :_parser_trans_targs
	private :_parser_trans_targs, :_parser_trans_targs=
end
self._parser_trans_targs = [
	49, 1, 2, 3, 4, 3, 12, 52, 
	4, 5, 12, 52, 49, 6, 5, 7, 
	6, 7, 8, 42, 9, 10, 13, 9, 
	10, 13, 11, 5, 12, 52, 11, 5, 
	12, 52, 51, 14, 15, 16, 20, 54, 
	15, 16, 20, 54, 17, 16, 18, 17, 
	18, 19, 21, 15, 16, 20, 54, 53, 
	22, 23, 14, 31, 22, 23, 31, 24, 
	26, 27, 41, 58, 25, 26, 27, 41, 
	58, 28, 27, 29, 28, 29, 30, 40, 
	23, 32, 33, 34, 38, 56, 33, 34, 
	38, 56, 35, 34, 36, 35, 36, 37, 
	39, 33, 34, 38, 56, 55, 24, 26, 
	27, 41, 58, 25, 57, 44, 44, 45, 
	46, 47, 46, 59, 47, 59, 0, 49, 
	50, 49, 1, 43, 49, 49, 49
]

class << self
	attr_accessor :_parser_trans_actions
	private :_parser_trans_actions, :_parser_trans_actions=
end
self._parser_trans_actions = [
	29, 0, 3, 5, 7, 0, 7, 7, 
	0, 13, 0, 0, 31, 15, 0, 15, 
	0, 0, 0, 0, 17, 42, 17, 0, 
	19, 0, 9, 63, 33, 33, 0, 36, 
	11, 11, 0, 19, 9, 63, 33, 80, 
	0, 36, 11, 71, 15, 0, 15, 0, 
	0, 19, 0, 39, 75, 67, 85, 57, 
	17, 45, 42, 17, 0, 19, 0, 0, 
	9, 63, 33, 80, 0, 0, 36, 11, 
	71, 15, 0, 15, 0, 0, 0, 19, 
	42, 19, 9, 63, 33, 80, 0, 36, 
	11, 71, 15, 0, 15, 0, 0, 19, 
	19, 39, 75, 67, 85, 57, 17, 39, 
	75, 67, 85, 17, 57, 1, 0, 3, 
	5, 7, 0, 7, 0, 0, 0, 25, 
	60, 27, 1, 0, 51, 48, 54
]

class << self
	attr_accessor :_parser_to_state_actions
	private :_parser_to_state_actions, :_parser_to_state_actions=
end
self._parser_to_state_actions = [
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	21, 21, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0
]

class << self
	attr_accessor :_parser_from_state_actions
	private :_parser_from_state_actions, :_parser_from_state_actions=
end
self._parser_from_state_actions = [
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 23, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0
]

class << self
	attr_accessor :_parser_eof_trans
	private :_parser_eof_trans, :_parser_eof_trans=
end
self._parser_eof_trans = [
	0, 1, 1, 1, 1, 13, 13, 13, 
	13, 13, 13, 13, 13, 13, 13, 13, 
	13, 13, 13, 13, 13, 13, 13, 13, 
	13, 13, 13, 13, 13, 13, 13, 13, 
	13, 13, 13, 13, 13, 13, 13, 13, 
	13, 13, 13, 1, 1, 1, 1, 1, 
	0, 0, 122, 125, 126, 125, 126, 125, 
	126, 125, 126, 127
]

class << self
	attr_accessor :parser_start
end
self.parser_start = 49;
class << self
	attr_accessor :parser_first_final
end
self.parser_first_final = 49;
class << self
	attr_accessor :parser_error
end
self.parser_error = 0;

class << self
	attr_accessor :parser_en_Closeout
end
self.parser_en_Closeout = 48;
class << self
	attr_accessor :parser_en_main
end
self.parser_en_main = 49;


# line 118 "scan.rl"
      
# line 356 "scan.rb"
begin
	p ||= 0
	pe ||= data.length
	cs = parser_start
	ts = nil
	te = nil
	act = 0
end

# line 119 "scan.rl"
      
# line 368 "scan.rb"
begin
	_klen, _trans, _keys, _acts, _nacts = nil
	_goto_level = 0
	_resume = 10
	_eof_trans = 15
	_again = 20
	_test_eof = 30
	_out = 40
	while true
	_trigger_goto = false
	if _goto_level <= 0
	if p == pe
		_goto_level = _test_eof
		next
	end
	if cs == 0
		_goto_level = _out
		next
	end
	end
	if _goto_level <= _resume
	_acts = _parser_from_state_actions[cs]
	_nacts = _parser_actions[_acts]
	_acts += 1
	while _nacts > 0
		_nacts -= 1
		_acts += 1
		case _parser_actions[_acts - 1]
			when 14 then
# line 1 "scan.rl"
		begin
ts = p
		end
# line 1 "scan.rl"
# line 403 "scan.rb"
		end # from state action switch
	end
	if _trigger_goto
		next
	end
	_keys = _parser_key_offsets[cs]
	_trans = _parser_index_offsets[cs]
	_klen = _parser_single_lengths[cs]
	_break_match = false
	
	begin
	  if _klen > 0
	     _lower = _keys
	     _upper = _keys + _klen - 1

	     loop do
	        break if _upper < _lower
	        _mid = _lower + ( (_upper - _lower) >> 1 )

	        if data[p] < _parser_trans_keys[_mid]
	           _upper = _mid - 1
	        elsif data[p] > _parser_trans_keys[_mid]
	           _lower = _mid + 1
	        else
	           _trans += (_mid - _keys)
	           _break_match = true
	           break
	        end
	     end # loop
	     break if _break_match
	     _keys += _klen
	     _trans += _klen
	  end
	  _klen = _parser_range_lengths[cs]
	  if _klen > 0
	     _lower = _keys
	     _upper = _keys + (_klen << 1) - 2
	     loop do
	        break if _upper < _lower
	        _mid = _lower + (((_upper-_lower) >> 1) & ~1)
	        if data[p] < _parser_trans_keys[_mid]
	          _upper = _mid - 2
	        elsif data[p] > _parser_trans_keys[_mid+1]
	          _lower = _mid + 2
	        else
	          _trans += ((_mid - _keys) >> 1)
	          _break_match = true
	          break
	        end
	     end # loop
	     break if _break_match
	     _trans += _klen
	  end
	end while false
	_trans = _parser_indicies[_trans]
	end
	if _goto_level <= _eof_trans
	cs = _parser_trans_targs[_trans]
	if _parser_trans_actions[_trans] != 0
		_acts = _parser_trans_actions[_trans]
		_nacts = _parser_actions[_acts]
		_acts += 1
		while _nacts > 0
			_nacts -= 1
			_acts += 1
			case _parser_actions[_acts - 1]
when 0 then
# line 5 "scan.rl"
		begin
 mark_pfx = p 		end
# line 5 "scan.rl"
when 1 then
# line 6 "scan.rl"
		begin

	  if data[mark_pfx..p-1] != @prefix
      @nodes.last << data[mark_pfx-1..p]
	    	begin
		p += 1
		_trigger_goto = true
		_goto_level = _out
		break
	end

    end
			end
# line 6 "scan.rl"
when 2 then
# line 12 "scan.rl"
		begin
 mark_stg = p 		end
# line 12 "scan.rl"
when 3 then
# line 13 "scan.rl"
		begin
 @starttag = data[mark_stg..p-1] 		end
# line 13 "scan.rl"
when 4 then
# line 14 "scan.rl"
		begin
 mark_attr = p 		end
# line 14 "scan.rl"
when 5 then
# line 15 "scan.rl"
		begin

	  @attrs[@nat] = @vat 
			end
# line 15 "scan.rl"
when 6 then
# line 24 "scan.rl"
		begin
 mark_nat = p 		end
# line 24 "scan.rl"
when 7 then
# line 25 "scan.rl"
		begin
 @nat = data[mark_nat..p-1] 		end
# line 25 "scan.rl"
when 8 then
# line 26 "scan.rl"
		begin
 mark_vat = p 		end
# line 26 "scan.rl"
when 9 then
# line 27 "scan.rl"
		begin
 @vat = data[mark_vat..p-1] 		end
# line 27 "scan.rl"
when 10 then
# line 29 "scan.rl"
		begin
 @flavor = :open 		end
# line 29 "scan.rl"
when 11 then
# line 30 "scan.rl"
		begin
 @flavor = :self 		end
# line 30 "scan.rl"
when 12 then
# line 31 "scan.rl"
		begin
 @flavor = :close 		end
# line 31 "scan.rl"
when 15 then
# line 1 "scan.rl"
		begin
te = p+1
		end
# line 1 "scan.rl"
when 16 then
# line 69 "scan.rl"
		begin
act = 1;		end
# line 69 "scan.rl"
when 17 then
# line 78 "scan.rl"
		begin
act = 2;		end
# line 78 "scan.rl"
when 18 then
# line 78 "scan.rl"
		begin
te = p+1
 begin 
	    @nodes.last << data[p]
	    @tagstart = p
	   end
		end
# line 78 "scan.rl"
when 19 then
# line 69 "scan.rl"
		begin
te = p
p = p - 1; begin 
	    tag = {:prefix=>@prefix, :name=>@starttag, :flavor => @flavor, :attrs => @attrs}
	    @prefix = nil
	    @name = nil
	    @flavor = :tasteless
	    @attrs = {}
	    @nodes << tag << ''
      	begin
		p += 1
		_trigger_goto = true
		_goto_level = _out
		break
	end

	   end
		end
# line 69 "scan.rl"
when 20 then
# line 78 "scan.rl"
		begin
te = p
p = p - 1; begin 
	    @nodes.last << data[p]
	    @tagstart = p
	   end
		end
# line 78 "scan.rl"
when 21 then
# line 78 "scan.rl"
		begin
 begin p = ((te))-1; end
 begin 
	    @nodes.last << data[p]
	    @tagstart = p
	   end
		end
# line 78 "scan.rl"
when 22 then
# line 1 "scan.rl"
		begin
	case act
	when 1 then
	begin begin p = ((te))-1; end

	    tag = {:prefix=>@prefix, :name=>@starttag, :flavor => @flavor, :attrs => @attrs}
	    @prefix = nil
	    @name = nil
	    @flavor = :tasteless
	    @attrs = {}
	    @nodes << tag << ''
      	begin
		p += 1
		_trigger_goto = true
		_goto_level = _out
		break
	end

	  end
	when 2 then
	begin begin p = ((te))-1; end

	    @nodes.last << data[p]
	    @tagstart = p
	  end
end 
			end
# line 1 "scan.rl"
# line 645 "scan.rb"
			end # action switch
		end
	end
	if _trigger_goto
		next
	end
	end
	if _goto_level <= _again
	_acts = _parser_to_state_actions[cs]
	_nacts = _parser_actions[_acts]
	_acts += 1
	while _nacts > 0
		_nacts -= 1
		_acts += 1
		case _parser_actions[_acts - 1]
when 13 then
# line 1 "scan.rl"
		begin
ts = nil;		end
# line 1 "scan.rl"
# line 666 "scan.rb"
		end # to state action switch
	end
	if _trigger_goto
		next
	end
	if cs == 0
		_goto_level = _out
		next
	end
	p += 1
	if p != pe
		_goto_level = _resume
		next
	end
	end
	if _goto_level <= _test_eof
	if p == eof
	if _parser_eof_trans[cs] > 0
		_trans = _parser_eof_trans[cs] - 1;
		_goto_level = _eof_trans
		next;
	end
end
	end
	if _goto_level <= _out
		break
	end
	end
	end

# line 120 "scan.rl"
      return p
    end
  end
end