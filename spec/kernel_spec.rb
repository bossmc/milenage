require 'milenage'

def hex2str(hex)
  [hex].pack("H*")
end

describe Kernel, "f1 and f1_star" do
  it "passes test set #1" do
    key = hex2str("465b5ce8b199b49faa5f0a2ee238a6bc")
    rand = hex2str("23553cbe9637a89d218ae64dae47bf35")
    sqn = hex2str("ff9bb4d0b607")
    amf = hex2str("b9b9")
    op = hex2str("cdc202d5123e20f62b6d676ac72cb318")
    m = Milenage::Kernel.new(key)
    m.op = op
    expect(m.opc).to eq(hex2str("cd63cb71954a9f4e48a5994e37a02baf"))
    expect(m.f1(rand, sqn, amf)).to eq(hex2str("4a9ffac354dfafb3"))
    expect(m.f1_star(rand, sqn, amf)).to eq(hex2str("01cfaf9ec4e871e9"))
  end
end

describe Kernel, "f2, f3 and f5" do
  it "passes test set #1" do
    key = hex2str("465b5ce8b199b49faa5f0a2ee238a6bc")
    rand = hex2str("23553cbe9637a89d218ae64dae47bf35")
    op = hex2str("cdc202d5123e20f62b6d676ac72cb318")
    m = Milenage::Kernel.new(key)
    m.op = op
    expect(m.opc).to eq(hex2str("cd63cb71954a9f4e48a5994e37a02baf"))
    expect(m.f2(rand)).to eq(hex2str("a54211d5e3ba50bf"))
    expect(m.f3(rand)).to eq(hex2str("b40ba9a3c58b2a05bbf0d987b21bf8cb"))
    expect(m.f5(rand)).to eq(hex2str("aa689c648370"))
  end
end

describe Kernel, "f4 and f5_star" do
  it "passes test set #1" do
    key = hex2str("465b5ce8b199b49faa5f0a2ee238a6bc")
    rand = hex2str("23553cbe9637a89d218ae64dae47bf35")
    op = hex2str("cdc202d5123e20f62b6d676ac72cb318")
    m = Milenage::Kernel.new(key)
    m.op = op
    expect(m.opc).to eq(hex2str("cd63cb71954a9f4e48a5994e37a02baf"))
    expect(m.f4(rand)).to eq(hex2str("f769bcd751044604127672711c6d3441"))
    expect(m.f5_star(rand)).to eq(hex2str("451e8beca43b"))
  end
end
