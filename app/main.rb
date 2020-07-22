class Fader
  attr_accessor :solid, :fresh
  @@faders = []
  
  def initialize solid
    puts "solid(#{args.state.tick_count}):\n #{solid.to_s}"
    @solid = solid
    @fresh = true
    @solid[:a] = 55
    @@faders << self
  end
  
  def self.live
      @@faders.select! {|fader| fader.solid[:a] > 1} # Culling the invisible faders.
      @@faders.each do |fader| # Fader lifecycle.
        if fader.fresh then fader.solid[:a] += 5 else fader.solid[:a] -= 1 end
        if fader.solid[:a] > 254 then fader.fresh = false end
      end
      nil
  end
  
  def self.solids
    @@faders.map(&:solid)
  end
end

def tick args
  args.state.Fader ||= Fader
  
  args.state.solids.pillowcase ||= {}
  
  if args.inputs.mouse.down # Tracking mouse drag initial position…
    args.state.inputs.mouse.held.point ||= args.inputs.mouse.down.point
  end
  if args.inputs.mouse.up # …and whether it's currently held.
    args.state.inputs.mouse.held.point = nil
    
    if args.state.solids.pillowcase # Making the current pillowcase a new fader.
      puts "args.state.solids.pillowcase.class(#{args.state.tick_count}):\n #{args.state.solids.pillowcase.class.to_s}"
      Fader.new args.state.solids.pillowcase
      args.state.solids.pillowcase = nil
    end
  end
  
  Fader.live
  args.outputs.solids << Fader.solids
  
  if args.state.inputs.mouse.held.point # Setting the current pillowcase.
    args.state.solids.pillowcase = {
      x: args.state.inputs.mouse.held.point.x,
      y: args.state.inputs.mouse.held.point.y,
      w: args.inputs.mouse.point.x - args.state.inputs.mouse.held.point.x,
      h: args.inputs.mouse.point.y - args.state.inputs.mouse.held.point.y,
      r: 255,
      g: 0,
      b: 0,
      a: 55,
      fresh: true
    }
  end
  
  args.outputs.solids << args.state.solids.pillowcase
  
  # args.outputs.labels << [20, 20, 'Faders ' + Fader.solids.size.to_s]
  # To make sure they do in fact get culled and not just invisible.
end
