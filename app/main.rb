class FaderParticle
    def initialize solid
        @x = solid.x
        @y = solid.y
        @w = solid.w
        @h = solid.h
        @a = 55
        @fresh = true
    end
    
    def alive
        @a > 0
    end
    
    def update inputs
        if @fresh then
            @a += 5
        else
            @a -= 1
        end
        
        if @a > 254 then
          @fresh = false
        end
    end
    
    def draw outputs
        outputs.solids << {
            x: @x,
            y: @y,
            w: @w,
            h: @h,
            r: 255,
            g: 0,
            b: 0,
            a: @a
        }
    end
    
    def tick args
        update args.inputs
        draw args.outputs
    end
end

class ParticleGroup
  def initialize
    @particles = []
  end
  
  def add p
    @particles << p
  end
  
  def update inputs
    # Cull the dead entities
    @particles.select! { |p| p.alive }
    @particles.each { |p| p.update inputs }
  end
  
  def draw outputs
    @particles.each { |p| p.draw outputs }
    
    # debugging
    outputs.labels << {
      x: 20,
      y: 20,
      text: 'Particles: ' + @particles.size.to_s
    }
  end
  
  def tick args
    update args.inputs
    draw args.outputs
  end
end

class Pillowcase
  def initialize initial
    @x = initial.x
    @y = initial.y
    @w = 0
    @h = 0
  end
  
  def solid
    {
      x: @x,
      y: @y,
      w: @w,
      h: @h,
      r: 255,
      g: 0,
      b: 0,
      a: 55,
    }
  end
  
  def update inputs
    @w = inputs.mouse.point.x - @x
    @h = inputs.mouse.point.y - @y
  end
  
  def draw outputs
    outputs.solids << solid
  end
  
  def tick args
    update args.inputs
    draw args.outputs
  end
end

class FadersAndPillowcase
  def initialize
    @faders = ParticleGroup.new
    @pillowcase = nil
  end
  
  def update inputs
    @faders.update inputs
      
    if inputs.mouse.down and @pillowcase == nil then
      @pillowcase = Pillowcase.new inputs.mouse.down.point
    end
    
    if @pillowcase then
      @pillowcase.update inputs
    end
    
    if inputs.mouse.up and @pillowcase != nil then
      @faders.add FaderParticle.new @pillowcase.solid
      @pillowcase = nil
    end
  end
  
  def draw outputs
    @faders.draw outputs
    
    if @pillowcase then
      @pillowcase.draw outputs
    end
  end
  
  def tick args
    update args.inputs
    draw args.outputs
  end
end

$effect = FadersAndPillowcase.new

def tick args
  $effect.update args.inputs
  $effect.draw args.outputs
end
