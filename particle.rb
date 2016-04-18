#!/usr/bin/env ruby

require 'set'

class Particle
  attr_reader :id, :color, :radius, :neighbors, :mass
  attr_accessor :position, :vx, :vy

  @@ids = 0

  def initialize(radius, mass, position, vx, vy)
    @@ids += 1
    @id = @@ids
    @radius = radius
    @color = nil
    @mass = mass
    @position = position
    @vx = vx
    @vy = vy
    @neighbors = Set.new
  end

  def eql?(other)
    self.id == other.id
  end

  def hash
    id
  end

  def to_s
    "id: #{@id}, radius: #{@radius}, mass: #{@mass}, position: #{@position}"
  end

  def x
    position.x
  end

  def y
    position.y
  end

  def add_neighbor(particle)
    @neighbors.add(particle)
  end

  def reset_neighbors
    @neighbors = Set.new
  end
end