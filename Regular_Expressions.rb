#code from Tom Stuart's Understanding Computation

require_relative './Finite_Automaton'

module Pattern
  def bracket(outer_precedence)
    if precedence < outer_precedence
      '(' + to_s + ')'
    else
      to_s
    end
  end

  def inspect
    "/#{self}/"
  end

  def matches?(string)
    to_nfa_design.accepts?(string)
  end
end

class Empty
  include Pattern

  def to_s
    ''
  end

  def precedence
    3
  end

  def to_nfa_design #converts pattern description syntax to an NFA
    start_state = Object.new
    accept_states = [start_state]
    rulebook = NFARulebook.new([]) #doesn't have any rules because it is matching emptiness
    NFADesign.new(start_state, accept_states, rulebook)
  end
end

class Literal < Struct.new(:character)
  include Pattern

  def to_s
    character
  end

  def precedence
    3
  end

  def to_nfa_design #converts pattern description syntax to an NFA
    start_state = Object.new
    accept_state = Object.new
    rule = FARule.new(start_state, character, accept_state)
    rulebook = NFARulebook.new([rule])
    NFADesign.new(start_state, [accept_state], rulebook)
  end
end

class Concatenate < Struct.new(:first, :second)
  include Pattern

  def to_s
    [first, second].map {|pattern| pattern.bracket(precedence) }.join
  end  

  def precedence
    1
  end

  def to_nfa_design #should map the accept_states of the first to the start state of the second via free moves
    first_nfa_design = first.to_nfa_design
    second_nfa_design = second.to_nfa_design
    start_state = first_nfa_design.start_state
    accept_states = second_nfa_design.accept_states
    rules = first_nfa_design.rulebook.rules + second_nfa_design.rulebook.rules
    #this is where the freemoves are created
    extra_rules = first_nfa_design.accept_states.map {|state| FARule.new(state, nil, second_nfa_design.start_state)}
    rulebook = NFARulebook.new(rules + extra_rules) #creates rulebook that includes the new free moves
    NFADesign.new(start_state, accept_states, rulebook)
  end
end

class Choose < Struct.new(:first, :second)
  include Pattern

  def to_s
    [first, second].map {|pattern| pattern.bracket(precedence) }.join('|')
  end

  def precedence
    0
  end

  def to_nfa_design #should create a brand new start state and create free moves to both of the start states of first and second, keeps all original accept states
    first_nfa_design = first.to_nfa_design
    second_nfa_design = second.to_nfa_design
    start_state = Object.new
    accept_states = first_nfa_design.accept_states + second_nfa_design.accept_states
    rules = first_nfa_design.rulebook.rules + second_nfa_design.rulebook.rules
    #this is where the new freemoves are created
    extra_rules = [first_nfa_design, second_nfa_design].map {|nfa_design| FARule.new(start_state, nil, nfa_design.start_state)
    }
    rulebook = NFARulebook.new(rules + extra_rules)
    NFADesign.new(start_state, accept_states, rulebook)
  end
end

class Repeat < Struct.new(:pattern)
  include Pattern

  def to_s
    pattern.bracket(precedence) + '*'
  end

  def precedence
    2
  end

  def to_nfa_design #should add free move from accept states to original start state so that it can accept more than one, and create a new start state, which is also an accept state, with a free move to the old start state 
    pattern_nfa_design = pattern.to_nfa_design
    start_state = Object.new
    accept_states = pattern_nfa_design.accept_states + [start_state]
    rules = pattern_nfa_design.rulebook.rules
    #creates the freemoves from accept states back to the new start state as well as a free move from the new start state to the old start state
    extra_rules = pattern_nfa_design.accept_states.map { |accept_state| FARule.new(accept_state, nil, pattern_nfa_design.start_state)} + 
      [FARule.new(start_state, nil, pattern_nfa_design.start_state)]
    rulebook = NFARulebook.new(rules + extra_rules)
    NFADesign.new(start_state, accept_states, rulebook)
  end
end











