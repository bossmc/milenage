require "milenage/version"

# All functions in the Milenage gem are contained in the Milenage namespace
module Milenage
  # The core class for calculating Milenage security functions.
  #
  # To use this class, determine the operator variant algorithm configuration
  # field (OP) or the pre-encrypted version of the same (OPc) and also
  # determine the user-specific key value (KEY).  Create an instance of the
  # kernel class, passing the key, then set the OP/OPc as needed:
  #
  #   m = Milenage::Kernel.new(KEY)
  #   m.op = OP # or m.opc = OPc
  #
  # At this point, the kernel instance can be used to calculate security 
  # functions for the user:
  #
  #   mac_a = m.f1(RAND, SQN, AMF)
  #   mac_s = m.f1_star(RAND, SQN, AMF)
  #   res = m.f2(RAND)
  #   ck = m.f3(RAND)
  #   ik = m.f4(RAND)
  #   ak = m.r5(RAND) # or ak = m.f5_star(RAND)
  #
  # You may change the OP/OPc at any time if needed:
  #
  #   m.op = NEW_OP
  #   m.opc = NEW_OPc
  class Kernel
    # Create a single user's kernel instance, remember to set OP or OPc before
    # attempting to use the security functions.
    #
    # To change the algorithm variables as described in TS 35.206 subclass
    # this Kernel class and modify `@c`, `@r` or `@kernel` after calling 
    # super. E.G.
    #
    #   class MyKernel < Kernel
    #     def initialize(key)
    #       super
    #       @r = [10, 20, 30, 40, 50]
    #     end
    #   end
    #
    # When doing this, `@kernel` should be set to a 128-bit MAC function with
    # the same API as `OpenSSL::Cipher`, if this is not the case, you may
    # need to overload {#enc} as well to match the API.
    def initialize(key)
      fail "KEY must be 128 bits" unless key.bytes.length == 16
      @key = key
      @c = [0, 1, 2, 4, 8].map { |i| [0, i].pack("Q>2") }
      @r = [64, 0, 32, 64, 96]
      @kernel = OpenSSL::Cipher::AES128.new(:ECB)
    end

    # Set the Operator Variant Algorithm Configuration field.
    #
    # Either this or {#opc=} must be called before any of the security
    # functions are evaluated.
    def op=(op)
      fail "OP must be 128 bits" unless op.bytes.length == 16
      @opc = xor(enc(op), op)
    end

    # Set the precomputed encoded Operator Variant Algorithm Configuration
    # field.  Note that there are no checks that this value is even feasible
    # for the given key.
    #
    # Either this or {#op=} must be called before any of the security
    # functions are evaluated.
    def opc=(opc)
      fail "OPc must be 128 bits" unless opc.bytes.length == 16
      @opc = opc
    end

    # Standard getter for the OPc.
    def opc
      fail "Must set OP or OPc before retrieving OPc" unless @opc
      @opc
    end

    # Calculate the network authentication code (MAC-A)
    def f1(rand, sqn, amf)
      step_a(rand, sqn, amf)[0..7]
    end

    # Calculate the resync authentication code (MAC-S)
    def f1_star(rand, sqn, amf)
      step_a(rand, sqn, amf)[8..15]
    end

    # Calculate the response (RES)
    def f2(rand)
      step_b(rand)[8..15]
    end

    # Calculate the confidentiallity key (CK)
    def f3(rand)
      step_c(rand)
    end

    # Calculate the integrity key (IK)
    def f4(rand)
      step_d(rand)
    end

    # Calculate the anonymity key (AK)
    def f5(rand)
      step_b(rand)[0..5]
    end

    # Calculate the anonymity resynch key (AK)
    def f5_star(rand)
      step_e(rand)[0..5]
    end

    private

    def enc(data)
      @kernel.encrypt
      @kernel.key = @key
      @kernel.padding = 0
      return (@kernel.update(data) + @kernel.final)
    end

    def step_0(rand)
      fail "Must set OP or OPc before calculating hashes" unless @opc
      fail "RAND must be 128 bits" unless rand.bytes.length == 16
      enc(xor(rand, @opc))
    end

    def step_a(rand, sqn, amf)
      fail "Must set OP or OPc before calculating hashes" unless @opc
      fail "SQN must be 48 bits" unless sqn.bytes.length == 6
      fail "AMF must be 16 bits" unless amf.bytes.length == 2
      tmp = (sqn + amf + sqn + amf)
      tmp = xor(tmp, @opc)
      tmp = roll(tmp, @r[0])
      tmp = xor(xor(tmp, @c[0]), step_0(rand))
      tmp = enc(tmp)
      xor(tmp, @opc)
    end

    def step_b(rand); step_x(rand, 1); end
    def step_c(rand); step_x(rand, 2); end
    def step_d(rand); step_x(rand, 3); end
    def step_e(rand); step_x(rand, 4); end

    def step_x(rand, idx)
      tmp = xor(step_0(rand), @opc)
      tmp = roll(tmp, @r[idx])
      tmp = xor(tmp, @c[idx])
      tmp = enc(tmp)
      tmp = xor(tmp, @opc)
    end

    def roll(data, count)
      data = data.unpack("Q>2")
      if count >= 64
        data[0], data[1] = data[1], data[0]
        count -= 64
      end

      out = [0, 0]
      out[0] = (data[0] << count) & 0xFFFFFFFFFFFFFFFF
      out[0] |= data[1] >> (64 - count)
      out[1] = (data[1] << count) & 0xFFFFFFFFFFFFFFFF
      out[1] |= data[0] >> (64 - count)

      return out.pack("Q>2")
    end

    def xor(a, b)
      a.bytes.zip(b.bytes).map do |a, b|
        a ^ b
      end.pack("c*")
    end
  end
end
