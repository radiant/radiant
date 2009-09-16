namespace :scan do
  desc 'Generate the parser'
  task 'build' => ['lib/radius/parser/scan.rb']
  
  desc 'Generate a PDF state graph from the parser'
  task 'graph' => ['doc/scan.pdf']
  
  desc 'turn the scan.rl file into a ruby file'
  file 'lib/radius/parser/scan.rb' => ['lib/radius/parser/scan.rl'] do |t|
    cd 'lib/radius/parser' do
      sh "ragel -R scan.rl"
    end
  end

  desc 'pdf of the ragel scanner'
  file 'doc/scan.pdf' => 'lib/radius/parser/scan.dot' do |t|
    cd 'lib/radius/parser' do
      sh "dot -Tpdf -o ../../../doc/scan.pdf scan.dot"
    end
  end

  file 'lib/radius/parser/scan.dot' => ['lib/radius/parser/scan.rl'] do |t|
    cd 'lib/radius/parser' do
      sh "ragel -Vp scan.rl > scan.dot"
    end
  end
end