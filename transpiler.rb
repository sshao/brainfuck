class Brainfuck
  class Transpiler
    def transpile(tree)
      buf = ""
      tree.each do |cmd|
        case cmd.keys.first
        when :ptr_inc then buf += "++p; "
        when :ptr_dec then buf += "--p; "
        when :inc then buf += "++*p; "
        when :dec then buf += "--*p; "
        when :puts then buf += "putchar(*p); "
        when :gets then buf += "*p = getchar(); "
        when :iteration then
          buf += "while (*p) { "
          buf += transpile(cmd[:iteration][:expr])
          buf += "} "
        else raise "case: #{cmd} ??"
        end
      end
      buf
    end
  end
end
