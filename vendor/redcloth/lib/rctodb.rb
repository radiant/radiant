#                                vim:ts=2:sw=4:
#
# rctodb.rb -- experimental hacking up of redcloth.rb to
#                 produce DocBook output.
#
# David A. Black
# 2004-2005
#
# I started this originally to help with PDF output for
# hieraki by Tobias Luetke.  why then asked me to put
# it on the RubyForge site for RedCloth.
#
# My approach has been to hack at the to_html stuff
# until it produces DocBook instead of HTML.  There's
# room for refinement....
#
# Simple usage:
#
# require 'rctodb.rb'
# puts RedCloth.new(File.read("redcloth_file")).to_docbook
#
# License::   same as redcloth.rb

require 'uri'

# = RedCloth
#
# RedCloth is a Ruby library for converting Textile and/or Markdown
# into HTML.  You can use either format, intermingled or separately.
# You can also extend RedCloth to honor your own custom text stylings.
#
# RedCloth users are encouraged to use Textile if they are generating
# HTML and to use Markdown if others will be viewing the plain text.
#
# == What is Textile?
#
# Textile is a simple formatting style for text
# documents, loosely based on some HTML conventions.
#
# == Sample Textile Text
#
#  h2. This is a title
#
#  h3. This is a subhead
#
#  This is a bit of paragraph.
#
#  bq. This is a blockquote.
#
# = Writing Textile
#
# A Textile document consists of paragraphs.  Paragraphs
# can be specially formatted by adding a small instruction
# to the beginning of the paragraph.
#
#  h[n].   Header of size [n].
#  bq.     Blockquote.
#  #       Numeric list.
#  *       Bulleted list.
#
# == Quick Phrase Modifiers
#
# Quick phrase modifiers are also included, to allow formatting
# of small portions of text within a paragraph.
#
#  \_emphasis\_
#  \_\_italicized\_\_
#  \*strong\*
#  \*\*bold\*\*
#  ??citation??
#  -deleted text-
#  +inserted text+
#  ^superscript^
#  ~subscript~
#  @code@
#  %(classname)span%
#
#  ==notextile== (leave text alone)
#
# == Links
#
# To make a hypertext link, put the link text in "quotation 
# marks" followed immediately by a colon and the URL of the link.
# 
# Optional: text in (parentheses) following the link text, 
# but before the closing quotation mark, will become a Title 
# attribute for the link, visible as a tool tip when a cursor is above it.
# 
# Example:
#
#  "This is a link (This is a title) ":http://www.textism.com
# 
# Will become:
# 
#  <a href="http://www.textism.com" title="This is a title">This is a link</a>
#
# == Images
#
# To insert an image, put the URL for the image inside exclamation marks.
#
# Optional: text that immediately follows the URL in (parentheses) will 
# be used as the Alt text for the image. Images on the web should always 
# have descriptive Alt text for the benefit of readers using non-graphical 
# browsers.
#
# Optional: place a colon followed by a URL immediately after the 
# closing ! to make the image into a link.
# 
# Example:
#
#  !http://www.textism.com/common/textist.gif(Textist)!
#
# Will become:
#
#  <img src="http://www.textism.com/common/textist.gif" alt="Textist" />
#
# With a link:
#
#  !/common/textist.gif(Textist)!:http://textism.com
#
# Will become:
#
#  <a href="http://textism.com"><img src="/common/textist.gif" alt="Textist" /></a>
#
# == Defining Acronyms
#
# HTML allows authors to define acronyms via the tag. The definition appears as a 
# tool tip when a cursor hovers over the acronym. A crucial aid to clear writing, 
# this should be used at least once for each acronym in documents where they appear.
#
# To quickly define an acronym in Textile, place the full text in (parentheses) 
# immediately following the acronym.
# 
# Example:
#
#  ACLU(American Civil Liberties Union)
#
# Will become:
#
#  <acronym title="American Civil Liberties Union">ACLU</acronym>
#
# == Adding Tables
#
# In Textile, simple tables can be added by seperating each column by
# a pipe.
#
#     |a|simple|table|row|
#     |And|Another|table|row|
#
# Attributes are defined by style definitions in parentheses.
#
#     table(border:1px solid black).
#     (background:#ddd;color:red). |{}| | | |
#
# == Using RedCloth
# 
# RedCloth is simply an extension of the String class, which can handle
# Textile formatting.  Use it like a String and output HTML with its
# RedCloth#to_html method.
#
#  doc = RedCloth.new "
#
#  h2. Test document
#
#  Just a simple test."
#
#  puts doc.to_html
#
# By default, RedCloth uses both Textile and Markdown formatting, with
# Textile formatting taking precedence.  If you want to turn off Markdown
# formatting, to boost speed and limit the processor:
#
#  class RedCloth::Textile.new( str )

class RedClothDocBook < String

    VERSION = '3.0.0'

    #
    # Two accessor for setting security restrictions.
    #
    # This is a nice thing if you're using RedCloth for
    # formatting in public places (e.g. Wikis) where you
    # don't want users to abuse HTML for bad things.
    #
    # If +:filter_html+ is set, HTML which wasn't
    # created by the Textile processor will be escaped.
    #
    # If +:filter_styles+ is set, it will also disable
    # the style markup specifier. ('{color: red}')
    #
    attr_accessor :filter_html, :filter_styles

    #
    # Accessor for toggling hard breaks.
    #
    # If +:hard_breaks+ is set, single newlines will
    # be converted to HTML break tags.  This is the
    # default behavior for traditional RedCloth.
    #
    attr_accessor :hard_breaks

    #
    # Establishes the markup predence.  Available rules include:
    #
    # == Textile Rules
    #
    # The following textile rules can be set individually.  Or add the complete
    # set of rules with the single :textile rule, which supplies the rule set in
    # the following precedence:
    #
    # refs_textile::          Textile references (i.e. [hobix]http://hobix.com/)
    # block_textile_table::   Textile table block structures
    # block_textile_lists::   Textile list structures
    # block_textile_prefix::  Textile blocks with prefixes (i.e. bq., h2., etc.)
    # inline_textile_image::  Textile inline images
    # inline_textile_link::   Textile inline links
    # inline_textile_span::   Textile inline spans
    # inline_textile_glyphs:: Textile entities (such as em-dashes and smart quotes)
    #
    # == Markdown
    #
    # refs_markdown::         Markdown references (for example: [hobix]: http://hobix.com/)
    # block_markdown_setext:: Markdown setext headers
    # block_markdown_atx::    Markdown atx headers
    # block_markdown_rule::   Markdown horizontal rules
    # block_markdown_bq::     Markdown blockquotes
    # block_markdown_lists::  Markdown lists
    # inline_markdown_link::  Markdown links
    attr_accessor :rules

    # Returns a new RedCloth object, based on _string_ and
    # enforcing all the included _restrictions_.
    #
    #   r = RedCloth.new( "h1. A <b>bold</b> man", [:filter_html] )
    #   r.to_html
    #     #=>"<h1>A &lt;b&gt;bold&lt;/b&gt; man</h1>"
    #
    def initialize( string, restrictions = [] )
        restrictions.each { |r| method( "#{ r }=" ).call( true ) }
        @rules = [:textile, :markdown]
        @levels = []
        super( string )

    end

    #
    # Generates HTML from the Textile contents.
    #
    #   r = RedCloth.new( "And then? She *fell*!" )
    #   r.to_html( true )
    #     #=>"And then? She <strong>fell</strong>!"
    #
    def to_docbook( *rules )
        rules = @rules if rules.empty?
        # make our working copy
        text = self.dup
        
        @urlrefs = {}
        @shelf = []
        textile_rules = [:refs_textile, :block_textile_table, :block_textile_lists,
                         :block_textile_prefix, :inline_textile_image, :inline_textile_link,
                         :inline_textile_code, :inline_textile_span, :inline_textile_glyphs]
        markdown_rules = [:refs_markdown, :block_markdown_setext, :block_markdown_atx, :block_markdown_rule,
                          :block_markdown_bq, :block_markdown_lists, 
                          :inline_markdown_reflink, :inline_markdown_link]
        @rules = rules.collect do |rule|
            case rule
            when :markdown
                markdown_rules
            when :textile
                textile_rules
            else
                rule
            end
        end.flatten

        # standard clean up
        incoming_entities text 
        clean_white_space text 

        # start processor
        pre_list = rip_offtags text
        refs text
        blocks text
        inline text
        smooth_offtags text, pre_list

        retrieve text

        orphans text

        text.gsub!( /<\/?notextile>/, '' )
        text.gsub!( /x%x%/, '&#38;' )
        text.strip!

        @levels.reverse.each do |level|
          text << "<\/#{level}>"
        end

        text

    end

    #######
    private
    #######
    #
    # Mapping of 8-bit ASCII codes to HTML numerical entity equivalents.
    # (from PyTextile)
    #
    TEXTILE_TAGS =

        [[128, 8364], [129, 0], [130, 8218], [131, 402], [132, 8222], [133, 8230], 
         [134, 8224], [135, 8225], [136, 710], [137, 8240], [138, 352], [139, 8249], 
         [140, 338], [141, 0], [142, 0], [143, 0], [144, 0], [145, 8216], [146, 8217], 
         [147, 8220], [148, 8221], [149, 8226], [150, 8211], [151, 8212], [152, 732], 
         [153, 8482], [154, 353], [155, 8250], [156, 339], [157, 0], [158, 0], [159, 376]].

        collect! do |a, b|
            [a.chr, ( b.zero? and "" or "&#{ b };" )]
        end

    #
    # Regular expressions to convert to HTML.
    #
    A_HLGN = /(?:(?:<>|<|>|\=|[()]+)+)/
    A_VLGN = /[\-^~]/
    C_CLAS = '(?:\([^)]+\))'
    C_LNGE = '(?:\[[^\]]+\])'
    C_STYL = '(?:\{[^}]+\})'
    S_CSPN = '(?:\\\\\d+)'
    S_RSPN = '(?:/\d+)'
    A = "(?:#{A_HLGN}?#{A_VLGN}?|#{A_VLGN}?#{A_HLGN}?)"
    S = "(?:#{S_CSPN}?#{S_RSPN}|#{S_RSPN}?#{S_CSPN}?)"
    C = "(?:#{C_CLAS}?#{C_STYL}?#{C_LNGE}?|#{C_STYL}?#{C_LNGE}?#{C_CLAS}?|#{C_LNGE}?#{C_STYL}?#{C_CLAS}?)"
    # PUNCT = Regexp::quote( '!"#$%&\'()*+,-./:;<=>?@[\\]^_`{|}~' )
    PUNCT = Regexp::quote( '!"#$%&\'*+,-./:;=?@\\^_`|~' )
    HYPERLINK = '(\S+?)([^\w\s/;=\?]*?)(?=\s|<|$)'

    # Text markup tags, don't conflict with block tags
    SIMPLE_HTML_TAGS = [
        'tt', 'b', 'i', 'big', 'small', 'em', 'strong', 'dfn', 'code', 
        'samp', 'kbd', 'var', 'cite', 'abbr', 'acronym', 'a', 'img', 'br',
        'br', 'map', 'q', 'sub', 'sup', 'span', 'bdo'
    ]

    # Elements to handle
    GLYPHS = [
    #   [ /([^\s\[{(>])?\'([dmst]\b|ll\b|ve\b|\s|:|$)/, '\1&#8217;\2' ], # single closing
        [ /([^\s\[{(>])\'/, '\1&#8217;' ], # single closing
        [ /\'(?=\s|s\b|[#{PUNCT}])/, '&#8217;' ], # single closing
        [ /\'/, '&#8216;' ], # single opening
    #   [ /([^\s\[{(])?"(\s|:|$)/, '\1&#8221;\2' ], # double closing
        [ /([^\s\[{(>])"/, '\1&#8221;' ], # double closing
        [ /"(?=\s|[#{PUNCT}])/, '&#8221;' ], # double closing
        [ /"/, '&#8220;' ], # double opening
        [ /\b( )?\.{3}/, '\1&#8230;' ], # ellipsis
        [ /\b([A-Z][A-Z0-9]{2,})\b(?:[(]([^)]*)[)])/, '<acronym title="\2">\1</acronym>' ], # 3+ uppercase acronym
### Taking out this caps one
        #[ /(^|[^"][>\s])([A-Z][A-Z0-9 ]{2,})([^<a-z0-9]|$)/, '\1<span class="caps">\2</span>\3' ], # 3+ uppercase caps
        [ /(\.\s)?\s?--\s?/, '\1&#8212;' ], # em dash
        [ /\s->\s/, ' &rarr; ' ], # en dash
        [ /\s-\s/, ' &#8211; ' ], # en dash
        [ /(\d+) ?x ?(\d+)/, '\1&#215;\2' ], # dimension sign
        [ /\b ?[(\[]TM[\])]/i, '&#8482;' ], # trademark
        [ /\b ?[(\[]R[\])]/i, '&#174;' ], # registered
        [ /\b ?[(\[]C[\])]/i, '&#169;' ] # copyright
    ]

    H_ALGN_VALS = {
        '<' => 'left',
        '=' => 'center',
        '>' => 'right',
        '<>' => 'justify'
    }

    V_ALGN_VALS = {
        '^' => 'top',
        '-' => 'middle',
        '~' => 'bottom'
    }

    QTAGS = [
        ['**', 'b'],
        ['*', 'strong'],
        ['??', 'cite'],
        ['-', 'del'],
        ['__', 'italic'],
        ['_', 'em'],
        ['%', 'phrase'],
        ['+', 'ins'],
        ['^', 'superscript'],
        ['~', 'subscript']
    ].collect do |rc, ht| 
        ttr = Regexp.quote(rc)
        punct = PUNCT.sub( Regexp::quote(rc), '' )
        re  = /(^|[\s\>#{punct}{(\[])
                #{ttr}
                (#{C})
                (?::(\S+?))?
                ([^\s#{ttr}]+?(?:[^\n]|\n(?!\n))*?)
                ([#{punct}]*?)
                #{ttr}
                (?=[\s\])}<#{punct}]|$)/xm 
        [re, ht]
    end 

    #
    # Flexible HTML escaping
    #
    def htmlesc( str, mode )
        str.gsub!( '&', '&amp;' )
        str.gsub!( '"', '&quot;' ) if mode != :NoQuotes
        str.gsub!( "'", '&#039;' ) if mode == :Quotes
        str.gsub!( '<', '&lt;')
        str.gsub!( '>', '&gt;')
    end

    # Search and replace for Textile glyphs (quotes, dashes, other symbols)
    def pgl( text )
        GLYPHS.each do |re, resub|
            text.gsub! re, resub
        end
    end

    # Parses Textile attribute lists and builds an HTML attribute string
    def pba( text_in, element = "" )
        
        return '' unless text_in

        text = text_in.dup

        rowspan = $1 if text =~ /\/(\d+)/

        atts = ""

        atts << "#{ $1 };" if not @filter_styles and
            text.sub!( /\{([^}]*)\}/, '' )

        lang = $1 if
            text.sub!( /\[([^)]+?)\]/, '' )

        cls = $1 if
            text.sub!( /\(([^()]+?)\)/, '' )
                        
        atts << "padding-left:#{ $1.length }em;" if
            text.sub!( /([(]+)/, '' )

        atts << "padding-right:#{ $1.length }em;" if text.sub!( /([)]+)/, '' )

        atts << " align=\"#{H_ALGN_VALS[$&]}\"" if text =~ A_HLGN
        atts << " vlign=\"#{V_ALGN_VALS[$&]}\"" if text =~ A_VLGN

        cls, id = $1, $2 if cls =~ /^(.*?)#(.*)$/
        
        atts << " class=\"#{ cls }\"" unless cls.to_s.empty?
        atts << " lang=\"#{ lang }\"" if lang
        atts << " id=\"#{ id }\"" if id
        atts << " morerows=\"#{ rowspan.to_i - 1 }\"" if rowspan
        
        atts
    end

    TABLE_RE = /^(?:table(_?#{S}#{A}#{C})\. ?\n)?^(#{A}#{C}\.? ?\|.*?\|)(\n\n|\Z)/m
    

    # Parses a Textile table block, building HTML from the result.
    def block_textile_table( text ) 
        text.gsub!( TABLE_RE ) do |matches|

            tatts, fullrow = $~[1..2]
            tatts = pba( tatts, 'table' )
            tatts << " frame=\"all\""

            rows = []

            fullrow.split( /\|$/m ).each do |row|

                ratts, row = pba( $1, 'row' ), $2 if row =~ /^(#{A}#{C}\. )(.*)/m

                cells = []
                headrow = nil
                row.split( '|' ).each do |cell|
                    headrow = true if /^_/.match(cell)
                    catts = ''
                    catts, cell = pba( $1, 'entry' ), $2 if cell =~ /^(_?#{S}#{A}#{C}\. ?)(.*)/

                    unless cell.strip.empty?
                        cells << "\t\t\t<entry#{ catts }>#{ cell }</entry>" 
                    end
                end
                rows << "\t<thead>" if headrow
                rows << "\t\t<row#{ ratts }>\n#{ cells.join( "\n" ) }\n\t\t</row>"
                rows << "\t</thead>" if headrow
            end
            "\t<table #{ tatts }>\n#{ rows.join( "\n" ) }\n\t</table>\n\n"
        end
    end

    # Parses a Textile table block, building HTML from the result.
    def block_textile_tablex( text ) 
        text.gsub!( TABLE_RE ) do |matches|

            tatts, fullrow = $~[1..2]
            tatts = pba( tatts, 'table' )
            rows = []

            fullrow.
            split( /\|$/m ).
            delete_if { |x| x.empty? }.
            each do |row|

                ratts, row = pba( $1, 'tr' ), $2 if row =~ /^(#{A}#{C}\. )(.*)/m
                
                cells = []
                row.split( '|' ).each do |cell|
                    ctyp = 'd'
                    ctyp = 'h' if cell =~ /^_/

                    catts = ''
                    catts, cell = pba( $1, 'td' ), $2 if cell =~ /^(_?#{S}#{A}#{C}\. ?)(.*)/

                    unless cell.strip.empty?
                        cells << "\t\t\t<t#{ ctyp }#{ catts }>#{ cell }</t#{ ctyp }>" 
                    end
                end
                rows << "\t\t<tr#{ ratts }>\n#{ cells.join( "\n" ) }\n\t\t</tr>"
            end
            "\t<table#{ tatts }>\n#{ rows.join( "\n" ) }\n\t</table>\n\n"
        end
    end

    LISTS_RE = /^([#*]+?#{C} .*?)$(?![^#*])/m
    LISTS_CONTENT_RE = /^([#*]+)(#{A}#{C}) (.*)$/m

    # Parses Textile lists and generates HTML
    def block_textile_lists( text ) 
        text.gsub!( LISTS_RE ) do |match|
            lines = match.split( /\n/ )
            last_line = -1
            depth = []
            lines.each_with_index do |line, line_id|
                if line =~ LISTS_CONTENT_RE 
                    tl,atts,content = $~[1..3]
                    if depth.last
                        if depth.last.length > tl.length
                            (depth.length - 1).downto(0) do |i|
                                break if depth[i].length == tl.length
                                lines[line_id - 1] << "</listitem>\n\t</#{ lT( depth[i] ) }>\n\t"
                                depth.pop
                            end
                        end
                        if depth.last.length == tl.length
                            lines[line_id - 1] << '</listitem>'
                        end
                    end
                    unless depth.last == tl
                        depth << tl
                        atts = pba( atts )
                        lines[line_id] = "\t<#{ lT(tl) }#{ atts }>\n\t<listitem>#{ content }"
                    else
                        lines[line_id] = "\t\t<listitem>#{ content }"
                    end
                    last_line = line_id

                else
                    last_line = line_id
                end
                if line_id - last_line > 1 or line_id == lines.length - 1
                    depth.delete_if do |v|
                        lines[last_line] << "</listitem>\n\t</#{ lT( v ) }>"
                    end
                end
            end
            lines.join( "\n" )
        end
    end

    CODE_RE = /
            (^|[\s>#{PUNCT}{(\[])            # 1 open bracket?
            @                                # opening
            (?:\|(\w+?)\|)?                  # 2 language
            (\S(?:[^\n]|\n(?!\n))*?)         # 3 code
            @                                # closing
            (?=[\s\]}\)<#{PUNCT}]|$)         # 4 closing bracket?
        /x 

    def inline_textile_code( text ) 
        text.gsub!( CODE_RE ) do |m|
            before,lang,code,after = $~[1..4]
            lang = " lang=\"#{ lang }\"" if lang
            "#{ before }<code#{ lang }>#{ code }</code>#{ after }"
        end
    end

    def lT( text ) 
        text =~ /\#$/ ? 'orderedlist' : 'itemizedlist'
    end

    def hard_break( text )
        text.gsub!( /(.)\n(?! *[#*\s|])/, "\\1<br />" ) if @hard_breaks
    end

    BLOCKS_GROUP_RE = /(#{
        ['#', '*', '>'].collect do |sym|
            sym = Regexp::quote( sym )
            '(?:\n*[' + sym + ' ](?:[^\n]|\n+[' + sym + ' ]|\n(?!\n|\Z))+)'
        end.join '|' 
    })|((?:[^\n]+|\n+ +|\n(?![#*\n]|\Z))+)/m

    NON_TAG_LINE_RE = '(^[^<]*\n)'
    WIDOW_RE = /(?=\A)(#{NON_TAG_LINE_RE}+)/
    ORPHAN_RE = /(#{NON_TAG_LINE_RE}+\Z)/

    def blocks( text, deep_code = false )
        text.gsub!( BLOCKS_GROUP_RE ) do |blk|

            plain = $2 ? true : false

            #blk.gsub!(WIDOW_RE) { |x| "<widow>#{x}</widow>" }
            # skip blocks that are complex HTML
            if blk =~ /^<\/?(\w+).*>/ and not SIMPLE_HTML_TAGS.include? $1
                blk
            else
                # search for indentation levels
                blk.strip!
                if blk.empty?
                    blk
                else
                    code_blk = nil
                    blk.gsub!( /((?:\n(?:\n^ +[^\n]*)+)+)/m ) do |iblk|
                        flush_left iblk
                        blocks iblk, plain
                        iblk.gsub( /^(\S)/, "\t\\1" )
                        if plain
                            code_blk = iblk; ""
                        else
                            iblk
                        end
                    end

                    block_applied = nil
                    @rules.each do |rule_name|
                        break if block_applied = ( rule_name.to_s.match(/^block_/) and method( rule_name ).call( blk ) )
                    end
                    unless block_applied
                        if deep_code
                            blk = "\t<programlisting>#{ blk }</programlisting>"
                        else
                            blk = "\t<para>#{ blk }</para>"
                        end
                    end
                    # hard_break blk
                    blk + "\n#{ code_blk }"
                end
            end

        end
    end

    def textile_bq( tag, atts, cite, content )
        cite, cite_title = check_refs( cite )
        cite = " cite=\"#{ cite }\"" if cite
        "\t<blockquote#{ cite }>\n\t\t<para#{ atts }>#{ content }</para>\n\t</blockquote>"
    end

    def textile_p( tag, atts, cite, content )

        str = ""
        if @levels[-1]
          str << "<\/#{@levels[-1]}>\n"
          @levels.pop
        end
        level = (/\d+/.match(tag)[0]).to_i - 1
        @levels.push("sect#{level}")
        
        str << "\t<sect#{level}><title>#{ content }</title>\n"
    end

    alias textile_h1 textile_p
    alias textile_h2 textile_p
    alias textile_h3 textile_p
    alias textile_h4 textile_p
    alias textile_h5 textile_p
    alias textile_h6 textile_p

    def textile_fn_( tag, num, atts, cite, content )
        atts << " id=\"fn#{ num }\""
        content = "<sup>#{ num }</sup> #{ content }"
        "\t<para#{ atts }>#{ content }</para>"
    end

    BLOCK_RE = /^(([a-z]+)(\d*))(#{A}#{C})\.(?::(\S+))? (.*)$/m

    def block_textile_prefix( text ) 
        if text =~ BLOCK_RE
            tag,tagpre,num,atts,cite,content = $~[1..6]
            atts = pba( atts )

            # pass to prefix handler
            if respond_to? "textile_#{ tag }", true
                text.gsub!( $&, method( "textile_#{ tag }" ).call( tag, atts, cite, content ) )
            elsif respond_to? "textile_#{ tagpre }_", true
                text.gsub!( $&, method( "textile_#{ tagpre }_" ).call( tagpre, num, atts, cite, content ) )
            end
        end
    end
    
    SETEXT_RE = /\A(.+?)\n([=-])[=-]* *$/m
    def block_markdown_setext( text )
        if text =~ SETEXT_RE
            tag = if $2 == "="; "h1"; else; "h2"; end
            blk, cont = "<#{ tag }>#{ $1 }</#{ tag }>", $'
            blocks cont
            text.replace( blk + cont )
        end
    end

    ATX_RE = /\A(\#{1,6})  # $1 = string of #'s
              [ ]*
              (.+?)       # $2 = Header text
              [ ]*
              \#*         # optional closing #'s (not counted)
              $/x
    def block_markdown_atx( text )
        if text =~ ATX_RE
            tag = "h#{ $1.length }"
            blk, cont = "<#{ tag }>#{ $2 }</#{ tag }>\n\n", $'
            blocks cont
            text.replace( blk + cont )
        end
    end

    MARKDOWN_BQ_RE = /\A(^ *> ?.+$(.+\n)*\n*)+/m

    def block_markdown_bq( text )
        text.gsub!( MARKDOWN_BQ_RE ) do |blk|
            blk.gsub!( /^ *> ?/, '' )
            flush_left blk
            blocks blk
            blk.gsub!( /^(\S)/, "\t\\1" )
            "<blockquote>\n#{ blk }\n</blockquote>\n\n"
        end
    end

    MARKDOWN_RULE_RE = /^#{
        ['*', '-', '_'].collect { |ch| '( ?' + Regexp::quote( ch ) + ' ?){3,}' }.join( '|' )
    }$/

    def block_markdown_rule( text )
        text.gsub!( MARKDOWN_RULE_RE ) do |blk|
            "<hr />"
        end
    end

    # todo
    def block_markdown_lists( text )
    end

    def inline_markdown_link( text )
    end

    def inline_textile_span( text ) 
      QTAGS.each do |ttr, ht|
        text.gsub!(ttr) do |m|
                start,atts,cite,content,tend = $~[1..5]
                atts = pba( atts )
                if ht == 'b'
                  atts << " role=\"bold\""
                  httmp = "emphasis"
                elsif ht == 'strong'
                  atts << " role=\"strong\""
                  httmp = "emphasis"
                elsif ht == 'italic'
                  httmp = "emphasis"
                else
                  httmp = ht
                end

                atts << " cite=\"#{ cite }\"" if cite

                "#{ start }<#{ httmp}#{ atts }>#{ content }#{ tend }</#{ httmp }>"

            end
        end
    end

    LINK_RE = /
            ([\s\[{(]|[#{PUNCT}])?     # $pre
            "                          # start
            (#{C})                     # $atts
            ([^"]+?)                   # $text
            \s?
            (?:\(([^)]+?)\)(?="))?     # $title
            ":
            (\S+?)                     # $url
            (\/)?                      # $slash
            ([^\w\/;]*?)               # $post
            (?=<|\s|$)
        /x 

    def inline_textile_link( text ) 
        text.gsub!( LINK_RE ) do |m|
            pre,atts,text,title,url,slash,post = $~[1..7]

            url, url_title = check_refs( url )
            title ||= url_title
            
            atts = pba( atts )
            atts = " url=\"#{ url }#{ slash }\"#{ atts }"
            atts << " alt=\"#{title}\"" if title
            atts = shelve( atts ) if atts
            
            link = "#{ pre }<ulink#{ atts }>#{ text }</ulink>#{ post }"
        end
    end

    MARKDOWN_REFLINK_RE = /
            \[([^\[\]]+)\]      # $text
            [ ]?                # opt. space
            (?:\n[ ]*)?         # one optional newline followed by spaces
            \[(.*?)\]           # $id
        /x 

    def inline_markdown_reflink( text ) 
        text.gsub!( MARKDOWN_REFLINK_RE ) do |m|
            text, id = $~[1..2]

            if id.empty?
                url, title = check_refs( text )
            else
                url, title = check_refs( id )
            end
            
            atts = " href=\"#{ url }\""
            atts << " title=\"#{ title }\"" if title
            atts = shelve( atts )
            
            "<a#{ atts }>#{ text }</a>"
        end
    end

    MARKDOWN_LINK_RE = /
            \[([^\[\]]+)\]      # $text
            \(                  # open paren
            [ \t]*              # opt space
            <?(.+?)>?           # $href
            [ \t]*              # opt space
            (?:                 # whole title
            (['"])              # $quote
            (.*?)               # $title
            \3                  # matching quote
            )?                  # title is optional
            \)
        /x 

    def inline_markdown_link( text ) 
        text.gsub!( MARKDOWN_LINK_RE ) do |m|
            text, url, quote, title = $~[1..4]

            atts = " href=\"#{ url }\""
            atts << " title=\"#{ title }\"" if title
            atts = shelve( atts )
            
            "<a#{ atts }>#{ text }</a>"
        end
    end

    TEXTILE_REFS_RE =  /(^ *)\[([^\n]+?)\](#{HYPERLINK})(?=\s|$)/
    MARKDOWN_REFS_RE = /(^ *)\[([^\n]+?)\]:\s+<?(#{HYPERLINK})>?(?:\s+"((?:[^"]|\\")+)")?(?=\s|$)/m

    def refs( text )
        @rules.each do |rule_name|
            method( rule_name ).call( text ) if rule_name.to_s.match /^refs_/
        end
    end

    def refs_textile( text ) 
        text.gsub!( TEXTILE_REFS_RE ) do |m|
            flag, url = $~[2..3]
            @urlrefs[flag.downcase] = [url, nil]
            nil
        end
    end
    
    def refs_markdown( text )
        text.gsub!( MARKDOWN_REFS_RE ) do |m|
            flag, url = $~[2..3]
            title = $~[6]
            @urlrefs[flag.downcase] = [url, title]
            nil
        end
    end

    def check_refs( text ) 
        ret = @urlrefs[text.downcase] if text
        ret || [text, nil]
    end

    IMAGE_RE = /
            (<p>|.|^)            # start of line?
            \!                   # opening
            (\<|\=|\>)?          # optional alignment atts
            (#{C})               # optional style,class atts
            (?:\. )?             # optional dot-space
            ([^\s(!]+?)          # presume this is the src
            \s?                  # optional space
            (?:\(((?:[^\(\)]|\([^\)]+\))+?)\))?   # optional title
            \!                   # closing
            (?::#{ HYPERLINK })? # optional href
        /x 

    def inline_textile_image( text ) 
        text.gsub!( IMAGE_RE )  do |m|
            stln,algn,atts,url,title,href,href_a1,href_a2 = $~[1..8]
            atts = pba( atts )
            atts = " src=\"#{ url }\"#{ atts }"
            atts << " title=\"#{ title }\"" if title
            atts << " alt=\"#{ title }\"" 
            # size = @getimagesize($url);
            # if($size) $atts.= " $size[3]";

            href, alt_title = check_refs( href ) if href
            url, url_title = check_refs( url )

            out = ''
            out << "<a#{ shelve( " href=\"#{ href }\"" ) }>" if href
            out << "<img#{ shelve( atts ) } />"
            out << "</a>#{ href_a1 }#{ href_a2 }" if href
            
            if algn 
                algn = h_align( algn )
                if stln == "<p>"
                    out = "<p style=\"float:#{ algn }\">#{ out }"
                else
                    out = "#{ stln }<div style=\"float:#{ algn }\">#{ out }</div>"
                end
            else
                out = stln + out
            end

            out
        end
    end

    def shelve( val ) 
        @shelf << val
        " <#{ @shelf.length }>"
    end
    
    def retrieve( text ) 
        @shelf.each_with_index do |r, i|
            text.gsub!( " <#{ i + 1 }>", r )
        end
    end

    def incoming_entities( text ) 
        ## turn any incoming ampersands into a dummy character for now.
        ## This uses a negative lookahead for alphanumerics followed by a semicolon,
        ## implying an incoming html entity, to be skipped

        text.gsub!( /&(?![#a-z0-9]+;)/i, "x%x%" )
    end

    def clean_white_space( text ) 
        # normalize line breaks
        text.gsub!( /\r\n/, "\n" )
        text.gsub!( /\r/, "\n" )
        text.gsub!( /\t/, '    ' )
        text.gsub!( /^ +$/, '' )
        text.gsub!( /\n{3,}/, "\n\n" )
        text.gsub!( /"$/, "\" " )

        # if entire document is indented, flush
        # to the left side
        flush_left text
    end

    def flush_left( text )
        indt = 0
        while text !~ /^ {#{indt}}\S/
            indt += 1
        end
        if indt.nonzero?
            text.gsub!( /^ {#{indt}}/, '' )
        end
    end

    def footnote_ref( text ) 
        text.gsub!( /\b\[([0-9]+?)\](\s)?/,
            '<sup><a href="#fn\1">\1</a></sup>\2' )
    end
    
    OFFTAGS = /(code|pre|kbd|notextile)/
    OFFTAG_MATCH = /(?:(<\/#{ OFFTAGS }>)|(<#{ OFFTAGS }[^>]*>))(.*?)(?=<\/?#{ OFFTAGS }|\Z)/mi
    #OFFTAG_MATCH = /(?:(<\/#{ OFFTAGS }>)|(<#{ OFFTAGS }[^>]*>))(.*?)(?=<\/?(code|pre|kbd|notextile)|\Z)/mi
    OFFTAG_OPEN = /<#{ OFFTAGS }/
    OFFTAG_CLOSE = /<\/?#{ OFFTAGS }/
    HASTAG_MATCH = /(<\/?\w[^\n]*?>)/m
    ALLTAG_MATCH = /(<\/?\w[^\n]*?>)|.*?(?=<\/?\w[^\n]*?>|$)/m

    def orphans(text)
    #  text.gsub!(/(\A|#{OFFTAG_CLOSE})(\n\n+)((?:[^<\n]+\n)+)/) { "#{$1}<orphan>#{$2}</orphan>\n" }
    #  text.gsub!(/(#{OFFTAG_CLOSE}[^<]*\n)((?:[^<\n]+\n)+)/) { "#{$1}<orphan>#{$2}</orphan>\n" }
      text
    end

    def inline_textile_glyphs( text, level = 0 )
        if text !~ HASTAG_MATCH
            pgl text
            footnote_ref text
        else
            codepre = 0
            text.gsub!( ALLTAG_MATCH ) do |line|
                ## matches are off if we're between <code>, <pre> etc.
                if $1
                    if @filter_html
                        htmlesc( line, :NoQuotes )
                    elsif line =~ OFFTAG_OPEN
                        codepre += 1
                    elsif line =~ OFFTAG_CLOSE
                        codepre -= 1
                        codepre = 0 if codepre < 0
                    end 
                elsif codepre.zero?
                    inline_textile_glyphs( line, level + 1 )
                else
                    htmlesc( line, :NoQuotes )
                end
                ## p [level, codepre, orig_line, line]

                line
            end
        end
    end

    #OFFTAG_MATCH = /(?:(<\/#{ OFFTAGS }>)|(<#{ OFFTAGS }[^>]*>))(.*?)(?=<\/?#{ OFFTAGS }|\Z)/mi
    #OFFTAG_MATCH = /(?:(<\/(code|pre)>)|(<(code|pre)[^>]*>))(.*?)(?=<\/?(code|pre)|\Z)/mi

    def rip_offtags( text )
        pre_list = []
        if text =~ /<.*>/
            ## strip and encode <pre> content
            codepre, used_offtags = 0, {}
            text.gsub!( OFFTAG_MATCH ) do |line|
                if $3
                    offtag, aftertag = $4, $5
                    codepre += 1
                    used_offtags[offtag] = true
                    if codepre - used_offtags.length > 0
                        htmlesc( line, :NoQuotes ) unless used_offtags['notextile']
                        pre_list.last << line
                        line = ""
                    else
                        htmlesc( aftertag, :NoQuotes ) if aftertag and not used_offtags['notextile']
                        line = "<redpre##{ pre_list.length }>"
                        pre_list << "#{ $3 }#{ aftertag }"
                    end
                elsif $1 and codepre > 0
                    if codepre - used_offtags.length > 0
                        htmlesc( line, :NoQuotes ) unless used_offtags['notextile']
                        pre_list.last << line
                        line = ""
                    end
                    codepre -= 1 unless codepre.zero?
                    used_offtags = {} if codepre.zero?
                end 

                ## Set 'orphan' text apart by an extra newline,
                ## to ensure that it gets processed
    #            line.sub!(/(.*<\/#{OFFTAGS}>\n)([^\n])/mi,"\\1\n\\3")
                 #line.sub!(/([^<\n]\n)+(?=[^\n]*#{OFFTAG_MATCH})/im, "<orphan>#{$1}</orphan>")
                 #line.sub!(/([^<]+\n)+(?=.*#{OFFTAG_MATCH})/i, "<orphan>#{$1}</orphan>")
                 #line.sub!(/([^<>]*[^>]\n)+/i, "<orphan>#{$1}</orphan>")
              line
            end
        end
        pre_list
    end

    def smooth_offtags( text, pre_list )
        unless pre_list.empty?
            ## replace <pre> content
            text.gsub!( /<redpre#(\d+)>/ ) { pre_list[$1.to_i] }
        end
    end
    def inline( text ) 
        @rules.each do |rule_name|
            method( rule_name ).call( text ) if rule_name.to_s.match /^inline_/
        end
    end

    def h_align( text ) 
        H_ALGN_VALS[text]
    end

    def v_align( text ) 
        V_ALGN_VALS[text]
    end

    def textile_popup_help( name, windowW, windowH )
        ' <a target="_blank" href="http://hobix.com/textile/#' + helpvar + '" onclick="window.open(this.href, \'popupwindow\', \'width=' + windowW + ',height=' + windowH + ',scrollbars,resizable\'); return false;">' + name + '</a><br />'
    end

end

