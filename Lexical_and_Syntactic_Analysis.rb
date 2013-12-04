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