=begin
Yet to comment but will
=end
require 'date'
require 'prawn'


class PdfGeneration
  def create_pdf arr, params
    if arr
      pdf = Prawn::Document.generate params + ".pdf", :page_layout => :landscape do |pdf|
        pdf.text "Henson Scap", :size => 18
        pdf.font "Helvetica"
        pdf.text "Details of Vulnerabilties as of #{Date.today.to_s} for '#{params}'", :style => :bold_italic
        pdf.stroke_horizontal_rule
        pdf.text "See next page", :size => 10
        pdf.move_down 10
        vuls = [["# Of Vuls","CVE-ID", "Summary", "Vulnerable Software"]]
        vuls += arr.each_with_index.map do |result, i|
          if result['obj']['vulnerable_software_list']
            vsl = result['obj']['vulnerable_software_list']['product']
          else
            vsl = "No software given"
          end#end if
          [
            i + 1,
            result['obj']['id'],
            result['obj']['summary'],
            vsl.to_s,
          ]

        end #end each_with_index loop


        pdf.table vuls, :header => true,
        :column_widths => { 0 => 50, 1 => 50, 3 => 350}, :row_colors => ["d2e3ed", "FFFFFF"] do
          style(columns(3)) {|x| x.align = :right }
        end#ends table
      end#end pdf creation
    end #end if arr
  end #end method

end#end class