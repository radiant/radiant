%%{
	machine parser;
	
	
	action _prefix { mark_pfx = p }
	action prefix {
	  if data[mark_pfx..p-1] != @prefix
	    closing = data[mark_pfx-1,1] == '/'
	    @nodes.last << data[mark_pfx-(closing ? 2 : 1)..p]
	    fbreak;
    end
	}
	action _starttag { mark_stg = p }
	action starttag { @starttag = data[mark_stg..p-1] }
	action _attr { mark_attr = p }
	action attr {
	  @attrs[@nat] = @vat 
	}
	
	action prematch {
	  @prematch_end = p
	  @prematch = data[0..p] if p > 0
	}
	
	action _nameattr { mark_nat = p }
	action nameattr { @nat = data[mark_nat..p-1] }
	action _valattr { mark_vat = p }
	action valattr { @vat = data[mark_vat..p-1] }
	
	action opentag  { @flavor = :open }
	action selftag  { @flavor = :self }
	action closetag { @flavor = :close }
	
	action stopparse {
	  @cursor = p;
	  fbreak;
	}
	
	
	Closeout := empty;
	
	# words
	PrefixChar = [\-A-Za-z0-9._?] ;
	NameChar = [\-A-Za-z0-9._:?] ;
	TagName = NameChar+ >_starttag %starttag;
	Prefix = PrefixChar+ >_prefix %prefix;
	
	Name = Prefix ":" TagName;
	
	NameAttr = NameChar+ >_nameattr %nameattr;
  Q1Char = ( "\\\'" | [^'] ) ;
  Q1Attr = Q1Char* >_valattr %valattr;
  Q2Char = ( "\\\"" | [^"] ) ;
  Q2Attr = Q2Char* >_valattr %valattr;
 
  Attr =  NameAttr space* "=" space* ('"' Q2Attr '"' | "'" Q1Attr "'") space* >_attr %attr;
  Attrs = (space+ Attr* | empty);
  
  CloseTrailer = "/>" %selftag;
  OpenTrailer = ">" %opentag;
  
  Trailer = (OpenTrailer | CloseTrailer);
  
	OpenOrSelfTag = Name Attrs? Trailer;
	CloseTag = "/" Name space* ">" %closetag;
	
	SomeTag = '<' (OpenOrSelfTag | CloseTag);
	
	main := |*
	  SomeTag => {
	    tag = {:prefix=>@prefix, :name=>@starttag, :flavor => @flavor, :attrs => @attrs}
	    @prefix = nil
	    @name = nil
	    @flavor = :tasteless
	    @attrs = {}
	    @nodes << tag << ''
      fbreak;
	  };
	  any => {
	    @nodes.last << data[p]
	    @tagstart = p
	  };
	*|;
}%%

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
      %% write data;
      %% write init;
      %% write exec;
      return p
    end
  end
end