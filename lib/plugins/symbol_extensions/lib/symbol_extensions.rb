module SymbolExtensions
  def symbolize
    self.to_s.symbolize
  end
end

Symbol.send :include, SymbolExtensions