class PdfGenerationService
  def initialize(memo_set)
    @memo_set = memo_set
  end
  
  def generate
    html = ApplicationController.render(
      template: "memo_sets/pdf",
      layout: "pdf",
      assigns: { memo_set: @memo_set }
    )
    
    WickedPdf.new.pdf_from_string(
      html,
      orientation: "Landscape",
      page_size: "A4",
      encoding: "UTF-8",
      margin: { top: 15, bottom: 15, left: 20, right: 20 },
      footer: {
        center: "[page] / [topage]",
        font_size: 10
      }
    )
  end
end
