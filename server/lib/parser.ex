defmodule Parser do
  def parse(data) do
    reg = ~r/\Ac(\d{1,9}) (?:s(\d{1,9}) )?([a-z_]{2,20})\n(.*)\Z/sm
    [_, c, s, cmd, payload] = Regex.run(reg, to_string(data))
    %Request{c: c, s: s, cmd: cmd, payload: String.strip(payload)}
  end
end
