class Deplo::FromCommandLine

  def initialize( title: nil , message: nil , content: nil )
    raise "Error" if [ title , message ].all?( &:nil? )
    @title = title
    @msg = message
    @content = content
    @condition = false
  end

  def set
    while !( @condition )
      puts @msg
      a = ::STDIN.gets.chomp
      @content = a
      puts message_after_input_string
      @condition = ::Deplo.yes_no( @condition )
    end

    actual_content
  end

  def self.set( *opt )
    self.new( *opt ).set
  end

  private

  def message_after_input_string
    "#{ @title }: \'#{ actual_content }\'"
  end

  def actual_content
    @content
  end

end
