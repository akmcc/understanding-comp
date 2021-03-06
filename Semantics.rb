#code from Understanding Computation by Tom Stuart

# definitions:
# operational semantics: explaining what a program means by showing what will happen when it is executed (interpreter)
# denotational semantics: explaining what a program means by translating it to another representation or language (assumes an established meaning of the new representation) (compiler)


require_relative './Simple_Kernel'

class Number < Struct.new(:value)

  include Simple_Kernel
  
  def to_s #does not take OoOps into account
    value.to_s
  end


  def reducible?
    false
  end

  def evaluate(environment) #big step operational semantics
    self
  end

  def to_ruby #denotational semantics
    " -> e { #{value.inspect} }" #not quite understanding this notation just yet, what's with the 'e'? 'e' is an environment variable?
  end
end

class Add < Struct.new(:left, :right)  

  include Simple_Kernel

  def to_s #does not take OoOps into account
    "#{left} + #{right}"
  end

  def reducible?
    true
  end

  def reduce(environment) #small step operational semantics
    if left.reducible?
      Add.new(left.reduce(environment), right)
    elsif right.reducible?
      Add.new(left, right.reduce(environment))
    else
      Number.new(left.value + right.value)
    end
  end

  def evaluate(environment) #big step operational semantics
    Number.new(left.evaluate(environment).value + right.evaluate(environment).value)  
  end

  def to_ruby #denotaional semantics
    "-> e { (#{left.to_ruby}).call(e) + (#{right.to_ruby}).call(e) }"
  end
end

class Multiply < Struct.new(:left, :right)
  
  include Simple_Kernel

  def to_s #does not take OoOps into account
    "#{left} * #{right}"
  end

  def reducible?
    true
  end

  def reduce(environment) #small step operational semantics
    if left.reducible?
      Multiply.new(left.reduce(environment), right)
    elsif right.reducible?
      Multiply.new(left, right.reduce(environment))
    else
      Number.new(left.value * right.value)
    end
  end

  def evaluate(environment) #big step operational semantics
    Number.new(left.evaluate(environment).value * right.evaluate(environment).value)  
  end

  def to_ruby #denotaional semantics
    "-> e { (#{left.to_ruby}).call(e) * (#{right.to_ruby}).call(e) }"
  end
end

class Boolean < Struct.new(:value)

  include Simple_Kernel
  
  def to_s
    value.to_s
  end

  def reducible?
    false
  end

  def evaluate(environment) #big step operational semantics
    self  
  end

  def to_ruby #denotational semantics
    " -> e { #{value.inspect} }"
  end
end

class LessThan < Struct.new(:left, :right)

  include Simple_Kernel

  def to_s
    "#{left} < #{right}"
  end

  def reducible?
    true
  end

  def reduce(environment) #small step operational semantics
    if left.reducible?
      LessThan.new(left.reduce(environment), right)
    elsif right.reducible?
      LessThan.new(left, right.reduce(environment))
    else
      Boolean.new(left.value < right.value)
    end
  end

  def evaluate(environment) #big step operational semantics
    Boolean.new(left.evaluate(environment).value < right.evaluate(environment).value)  
  end

  def to_ruby #denotaional semantics
    "-> e { (#{left.to_ruby}).call(e) < (#{right.to_ruby}).call(e) }"
  end
end

class GreaterThan < Struct.new(:left, :right)

  include Simple_Kernel

  def to_s
    "#{left} > #{right}"
  end

  def reducible?
    true
  end

  def reduce(environment) #small step operational semantics
    if left.reducible?
      GreaterThan.new(left.reduce(environment), right)
    elsif right.reducible?
      GreaterThan.new(left, right.reduce(environment))
    else
      Boolean.new(left.value > right.value)
    end
  end

  def evaluate(environment) #big step operational semantics
    Boolean.new(left.evaluate(environment).value > right.evaluate(environment).value)  
  end

  def to_ruby #denotaional semantics
    "-> e { (#{left.to_ruby}).call(e) > (#{right.to_ruby}).call(e) }"
  end
end

class Variable < Struct.new(:name) #only maps variable names onto irreducible values

  include Simple_Kernel

  def to_s
    name.to_s
  end

  def reducible? #can be reduced to the value/expression it represents.
    true
  end

  def reduce(environment) #small step operational semantics
    environment[name]
  end

  def evaluate(environment) #big step operational semantics
    environment[name]
  end

  def to_ruby #denotaional semantics
    "-> e { e[#{name.inspect}] }"
  end
end

class DoNothing #does not inherit from Struct because it has no attributes and Struct.new does not allow for an empty attribute list

  include Simple_Kernel

  def to_s
    "do_nothing"
  end

  def ==(other_statement)
    other_statement.instance_of?(DoNothing)
  end

  def reducible?
    false
  end

  def evaluate(environment) #big step operational semantics
    environment
  end

  def to_ruby #denotational semantics
    '-> e { e }'
  end
end

class Assign < Struct.new(:name, :expression)

  include Simple_Kernel

  def to_s
    "#{name} = #{expression}"
  end

  def reducible?
    true
  end

  def reduce(environment) #small step operational semantics
    if expression.reducible?
      [Assign.new(name, expression.reduce(environment)), environment ]
    else
      [DoNothing.new, environment.merge({ name => expression })]
    end
  end

  def evaluate(environment) #big step operational semantics
    environment.merge({name => expression.evaluate(environment)})
  end

  def to_ruby #denotational semantics
    "-> e { e.merge({ #{name.inspect} => (#{expression.to_ruby}).call(e) }) }"
  end
end

class If < Struct.new(:condition, :consequence, :alternative)

  include Simple_Kernel

  def to_s
    "if (#{condition}) { #{consequence} } else { #{alternative} }"
  end

  def reducible?
    true
  end

  def reduce(environment) #small step operational semantics
    if condition.reducible?
      [If.new(condition.reduce(environment), consequence, alternative), environment]
    else
      case condition
      when Boolean.new(true)
        [consequence, environment]
      when Boolean.new(false)
        [alternative, environment]
      end
    end
  end

  def evaluate(environment) #big step operational semantics
    case conditional.evaluate(environment)
    when Boolean.new(true)
      consequence.evaluate(environment)
    when Boolean.new(false)
      alternative.evaluate(environment)
    end
  end

  def to_ruby #denotational semantics
    "-> e { if (#{condition.to_ruby}).call(e)" +
      " then (#{consequence.to_ruby}).call(e)" +
      " else (#{alternative.to_ruby}).call(e)" +
      " end }"
  end
end

class Sequence < Struct.new(:first, :second)

  include Simple_Kernel

  def to_s
    "#{first}; #{second}"
  end

  def reducible?
    true
  end

  def reduce(environment) #small step operational semantics
    case first
    when DoNothing.new
      [second, environment]
    else
      reduced_first, reduced_environment = first.reduce(environment)
      [Sequence.new(reduced_first, second), reduced_environment]
    end
  end

  def evaluate(environment) #big step operational semantics
    second.evaluate(first.evaluate(environment))
  end

  def to_ruby #denotational semantics
    "-> e { (#{second.to_ruby}).call((#{first.to_ruby}).call(e)) }"
  end
end

class While < Struct.new(:condition, :body)

  include Simple_Kernel

  def to_s
    "while (#{condition}) { #{body} }"
  end

  def reducible?
    true
  end

  def reduce(environment) #small step operational semantics
    [If.new(condition, Sequence.new(body, self), DoNothing.new), environment] #creates the sequence because it needs to know the know the environment so it can update it to avoid infinite loop (I think that's why we're creation the sequence)
  end

  def evaluate(environment) #big step operational semantics
    case condition.evaluate(environment)
    when Boolean.new(true)
      evaluate(body.evaluate(environment))
    when Boolean.new(false)
      environment
    end
  end

  def to_ruby #denotational semantics
    "-> e {" +
      " while (#{condition.to_ruby}).call(e); e = (#{body.to_ruby}).call(e); end;" +
      " e" +
      " }"
  end
end

class Machine < Struct.new(:statement, :environment) #used for small-step reduction
  def step
    self.statement, self.environment = statement.reduce(environment) #is the self necessary?
  end

  def run
    while statement.reducible? 
      puts "#{statement}, #{environment}"
      step
    end
    puts "#{statement}, #{environment}"
  end
end


