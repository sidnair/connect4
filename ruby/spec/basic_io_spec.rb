require './src/connect4.rb'
require './src/player.rb'
require './src/basic_io.rb'

describe BasicIO do
  before(:each) do
    @stdin = StringIO.new
    @io = BasicIO.new(@stdin)
    @player = (Player.new(0, Connect4::RED))
  end

  it "parses valid input" do
    @stdin.puts("1")
    @stdin.rewind
    @io.prompt(@player).should be 0
  end

  it "parses negative numbers" do
    @stdin.puts("-1")
    @stdin.rewind
    @io.prompt(@player).should be(-2)
  end

  it "returns invalid sentinel on random characters" do
    @stdin.puts("@!(#!*@(#)!@#!$$@@#!XX1")
    @stdin.rewind
    @io.prompt(@player).should be(-1)
  end
end
