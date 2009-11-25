require File.dirname(__FILE__) + "/../lib/wicked_pdf.rb"

HTML_DOCUMENT = "<html><body>Hello World</body></html>"

describe "WickedPdf" do

  it "should generate PDF from html document" do
    wp = WickedPdf.new
    pdf = wp.pdf_from_string HTML_DOCUMENT
    pdf.start_with?("%PDF-1.4").should be_true
    pdf.rstrip.end_with?("%%EOF").should be_true
    pdf.length.should > 100
  end

  it "should raise exception when no path to wkhtmltopdf" do
    lambda { WickedPdf.new "" }.should raise_error 
  end

  it "should raise exception when pdf generation fails" do
    wp = WickedPdf.new("/i/do/not/exist/notwkhtmltopdf")
    lambda { wp.pdf_from_string HTML_DOCUMENT }.should raise_error 
  end

end

