#code from Tom Stuart's Understanding Computation

class Tape < Struct.new(:left, :current, :right, :blank)
  def inspect
    "#{left.join}(#{current})#{right.join}"
  end

  def write(character)
    Tape.new(left, character, right, blank)
  end

  def move_right
    Tape.new(left + [current], right[0] || blank , right.drop(1), blank)
  end

  def move_left
    Tape.new(left[0..-2], left[-1] || blank, [current] + right, blank)
  end
end

class TMConfiguration < Struct.new(:state, :tape)
end

class TMRule < Struct.new(:state, :character, :next_state, :write_character, :move)
  def applies_to?(configuration)
    configuration.state == state && configuration.tape.current == character
  end

  def follow(configuration)
    #returns a new configuration?
    TMConfiguration.new(next_state, next_tape(configuration))
  end

  def next_tape(configuration)
    written_tape = configuration.tape.write(write_character)
    case move
    when :left
      written_tape.move_left
    when :right
      written_tape.move_right
    end
  end
end

class DTMRulebook < Struct.new(:rules)

  def applies_to?(configuration)
    !rule_for(configuration).nil?
  end

  def next_configuration(configuration)
    rule_for(configuration).follow(configuration)
  end

  def rule_for(configuration)
    rules.detect {|rule| rule.applies_to?(configuration) }
  end
end

class DTM < Struct.new(:current_config, :accept_states, :rulebook)
  def accepting?
    accept_states.include?(current_config.state)
  end

  def step
    self.current_config = rulebook.next_configuration(current_config)
  end

  def run
    step until accepting? || stuck?
  end

  def stuck?
    !accepting? && !rulebook.applies_to?(current_config)
  end
end



rulebook = DTMRulebook.new([TMRule.new(1, '0', 2, '1', :right), TMRule.new(1, '1', 1, '0', :left),TMRule.new(1, '_', 2, '1', :right),TMRule.new(2, '0', 2, '0', :right),TMRule.new(2, '1', 2, '1', :right),TMRule.new(2, '_', 3, '_', :left)])