require './lib/app'
require 'pdfkit'

use PDFKit::Middleware
#run Sinatra::Application
run NistApp
