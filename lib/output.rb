#This file will be deleted and replaced
require_relative './pdfgeneration'
require_relative './jsongeneration'

class OutPut
  def out_put_format format, results, params
    if String === format
      if format === 'pdf'
        newPdf = PdfGeneration.new
        pdf = newPdf.create_pdf(results, params)
        puts "pdf created"
        puts 'Returns pdf'
  
      elsif format === 'json'
        newJson = JsonGeneration.new
        json = newJson.create_json(results, params)
        puts results
        puts 'Returns json'

      else
        puts "Invalid output"
      end
    end
  end
end