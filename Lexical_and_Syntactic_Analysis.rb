#code from Tom Stuart's Understanding Computation

#this is a more traditional approach to parsing by breaking the process in to two parts:
# 1. lexical analysis - breaking things down into tokens, decides which sequences of charcacters should produce which tokens
# 2. syntatic analysis - deciding whether sequences of tokens represents a valid program, if so, creates a parse tree

class LexicalAnalyzer < Struct.new(:string)

  GRAMMAR = [
    { token: 'i', pattern: /if/         },
    { token: 'e', pattern: /else/       },
    { token: 'w', pattern: /while/      },
    { token: 'd', pattern: /do-nothing/ },
    { token: '(', pattern: /\(/         },
    { token: ')', pattern: /\)/         },
    { token: '{', pattern: /\{/         },
    { token: '}', pattern: /\}/         },
    { token: ';', pattern: /\;/         },
    { token: '=', pattern: /\=/         },
    { token: '+', pattern: /\+/         },  
    { token: '*', pattern: /\*/         },
    { token: '<', pattern: /\</         },
    { token: 'n', pattern: /[0-9]+/     },
    { token: 'b', pattern: /true|false/ },
    { token: 'v', pattern: /[a-z]+/     }
  ]

  def analyze
    [].tap do |tokens|
      while more_tokens?
        tokens.push(next_token)
      end
    end
  end

  def more_tokens?
    !string.empty?
  end

  def next_token
    rule, match = rule_matching(string)
    self.string = string_after(match)
    rule[:token] #is the rule a line of the GRAMMAR?
  end

  def rule_matching(string)
    matches = GRAMMAR.map {|rule| match_at_beginning(rule[:pattern], string) }
    rules_with_matches = GRAMMAR.zip(matches).reject {|rule, match| match.nil? }
    rule_with_longest_match(rules_with_matches)
  end

  def match_at_beginning(pattern, string)
    /\A#{pattern}/.match(string)
  end

  def rule_with_longest_match(rules_with_matches)  
    rules_with_matches.max_by { |rule, match| match.to_s.length } #max_by returns the max based on the info passed in the block, in this case, the length of the match
  end

  def string_after(match)
    match.post_match.lstrip #lstrip removes only the leading white spaces
  end
end



# SYNTACTIC GRAMMAR
#
# this is a context-free grammar which means it doesn't specify the context in which each peice may appear
# for example: an assignment always consists of a variable name, an equal sign, and an expression REGARDLESS of other tokens around it.
#
# <statement>   ::= <while> | <assign>
# <while>       ::= 'w' '(' <expression> ')' '{' <statement> '}'
# <assign>      ::= 'v' '=' <expression>
# <expression>  ::= <less-than>
# <less-than>   ::= <multiply> '<' <less-than> | <multiply>
# <multiply>    ::= <term> '*' <multiply> | <term>
# <term>        ::= 'n' | 'v'
#
#
# can translate these grammar rules into PDA rules
#
# example:
#
# irb(main):004:0> symbol_rules = [\
# irb(main):005:1* PDARule.new(2, nil, 2, 'S', ['W']),\
# irb(main):007:1* PDARule.new(2, nil, 2, 'W', ['w', '(', 'E', ')', '{', 'S', '}']),\
# irb(main):008:1* PDARule.new(2, nil, 2, 'A', ['v', '=', 'E']),\
# irb(main):009:1* PDARule.new(2, nil, 2, 'E', ['L']),\
# irb(main):010:1* PDARule.new(2, nil, 2, 'L', ['M', '<', 'L']),\
# irb(main):011:1* PDARule.new(2, nil, 2, 'L', ['M']),\
# irb(main):012:1* PDARule.new(2, nil, 2, 'M', ['T', '*', 'M']),\
# irb(main):013:1* PDARule.new(2, nil, 2, 'M', ['T']),\
# irb(main):014:1* PDARule.new(2, nil, 2, 'T', ['n']),\
# irb(main):015:1* PDARule.new(2, nil, 2, 'T', ['v'])]