require 'pca'
require 'csv'
require 'gnuplot'

## Trying to find which classes should be refactored first

pca = PCA.new components: 1
metrics = CSV.read('files/classes.csv', { :col_sep => ';', :headers => true })
data_2d = metrics.map { |row| [row['wmc'].to_i, row['ca'].to_i]}
data_1d = pca.fit_transform data_2d
evr = pca.explained_variance_ratio
puts evr

final = Array.new
metrics.each_with_index do |row, index|
  final << {name: row['name'], wmc: row['wmc'], ca: row['ca'], pc1: data_1d[index]}
end

sorted = final.sort_by { |h| h[:pc1] }
sorted.each do |hash|
  puts "#{hash[:name].ljust(50)}#{hash[:wmc].to_s.rjust(5)}#{hash[:ca].to_s.rjust(5)}#{hash[:pc1].to_s.rjust(25)}"
end

Gnuplot.open do |gp|
  Gnuplot::Plot.new(gp) do |plot|
    plot.title "Transformed data"
    plot.terminal "png"
    plot.output "files/transformed.png"

    plot.xrange "[0:70]"
    plot.yrange "[0:70]"


    x = sorted.map { |hash| hash[:wmc]}
    y = sorted.map { |hash| hash[:ca]}

    plot.data << Gnuplot::DataSet.new([x, y]) do |ds|
      ds.notitle
    end
  end
end