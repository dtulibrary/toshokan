# based on http://www.natontesting.com/2010/01/11/updated-script-to-list-all-cucumber-step-definitions/
namespace :cucumber do
  desc 'List all defined steps'
  task :steps do
    require 'hirb'

    extend Hirb::Console
    puts "CUCUMBER steps:"
    puts ""
    step_definition_dir = "features/step_definitions"

    Dir.glob(File.join(step_definition_dir,'**/*.rb')).each do |step_file|
      puts "File: #{step_file}"
      puts ""
      results = []
      File.new(step_file).read.each_line.each_with_index do |line, number|

        next unless line =~ /^\s*(?:Given|When|Then)\s+|\//
        res = /(?:Given|When|Then)[\s\(]*\/(.*)\/([imxo]*)[\s\)]*do\s*(?:$|\|(.*)\|)/.match(line)
        next unless res
        matches = res.captures
        results << OpenStruct.new(
          :steps => matches[0],
          :modifier => matches[1],
          :args => matches[2]
        )
      end
      table results, :resize => false, :fields=>[:steps, :modifier, :args]
      puts ""
    end
  end
end
# alternative version ... single box :)
#    task :steps do
#      require 'hirb'
#      extend Hirb::Console
#      puts "CUCUMBER steps:"
#      puts ""
#      step_definition_dir = "features/step_definitions"
#
#      results = []
#      add_empty = lambda { results << OpenStruct.new(:step => "", :line_number => "", :args => "") }
#      add_step = lambda do |step, line_number, args|
#        results << OpenStruct.new(:step => step, :line_number => line_number, :args => args)
#      end
#      Dir.glob(File.join(step_definition_dir,'**/*.rb')).each do |step_file|
#
#        add_empty.call
#        add_step.call("File: #{step_file}", "", "")
#        add_empty.call
#
#        File.new(step_file).read.each_line.each_with_index do |line, number|
#
#          next unless line =~ /^\s*(?:Given|When|Then)\s+|\//
#          res = /(?:Given|When|Then)[\s\(]*\/(.*)\/([imxo]*)[\s\)]*do\s*(?:$|\|(.*)\|)/.match(line)
#          next unless res
#          matches = res.captures
#          add_step.call(matches[0], number, matches[2])
#        end
#      end
#      table results, :resize => false, :fields=>[:step, :line_number, :args]
#    end
