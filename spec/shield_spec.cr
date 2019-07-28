require "./spec_helper.cr"

_id_ = "02240382-2937-F4A7-254E-F1E7DE9B6782"
_def = [
  {
    secretKey:  "n+1Lp5Nss2#Mv&Vxu&Hn",
    iterations: 8192,
    masterKey:  "abc123",
    pinCode:    "736723",
    userName:   {
      iterations: 8192,
      length:     12,
      nonce:      "Name",
    },
    email: {
      iterations: 8192,
      length:     12,
      domain:     "example.com",
    },
    nameWithEmail: {
      name:  "qkjnk9vvxuu6",
      email: "yikmtrs1l8s5@example.com",
    },
  },
  {
    secretKey:  "iW65i67Nu6TrZ#h8Ww57",
    iterations: 16384,
    masterKey:  "abc123",
    pinCode:    "208584",
    userName:   {
      iterations: 16384,
      length:     12,
      nonce:      "Name",
    },
    email: {
      iterations: 16384,
      length:     12,
      domain:     "example.com",
    },
    nameWithEmail: {
      name:  "vklw91hpgms4",
      email: "lhhl9mh857o0@example.com",
    },
  },
  {
    secretKey:  "Ym1lkj5vWw05i38Nx#uI",
    iterations: 32768,
    masterKey:  "abc123",
    pinCode:    "602875",
    userName:   {
      iterations: 32768,
      length:     12,
      nonce:      "Name",
    },
    email: {
      iterations: 32768,
      length:     12,
      domain:     "example.com",
    },
    nameWithEmail: {
      name:  "hjgov94s7z37",
      email: "tqqnk5u38l1k@example.com",
    },
  },
  {
    secretKey:  "l56Vq3Gly)SspX3hwv#J",
    iterations: 65536,
    masterKey:  "abc123",
    pinCode:    "898646",
    userName:   {
      iterations: 65536,
      length:     12,
      nonce:      "Name",
    },
    email: {
      iterations: 65536,
      length:     12,
      domain:     "example.com",
    },
    nameWithEmail: {
      name:  "uzgg8019yy88",
      email: "stqwhk0r6s7g@example.com",
    },
  },
  {
    secretKey:  "k0yup5L5ux(YVh91x9xK",
    iterations: 131072,
    masterKey:  "abc123",
    pinCode:    "335680",
    userName:   {
      iterations: 131072,
      length:     12,
      nonce:      "Name",
    },
    email: {
      iterations: 131072,
      length:     12,
      domain:     "example.com",
    },
    nameWithEmail: {
      name:  "qtozs417s4rs",
      email: "rlyh52g98tl6@example.com",
    },
  },
]

describe Shield do
  it "Test SecretKey / PinCode / UserName / Email Iterations" do
    _def.size.times do |ti|
      option = Shield::Option.new
      user_name = option.nameEmail.userName
      user_name.iterations = _def[ti][:userName][:iterations]
      user_name.length = _def[ti][:userName][:length]
      user_name.nonce = _def[ti][:userName][:nonce]

      email = option.nameEmail.email
      email.iterations = _def[ti][:email][:iterations]
      email.length = _def[ti][:email][:length]
      email.domain = _def[ti][:email][:domain]

      master_key = _def[ti][:masterKey]
      pin_code = _def[ti][:pinCode]
      secret_key = _def[ti][:secretKey]

      option.iterations = _def[ti][:iterations]
      option.enablePin = true
      builder = Shield::Builder.new option

      builder.create_key(master_key, _id_) do |done?, data|
        # SecretKey
        data.should eq secret_key if done?

        # PinCode
        builder.create_pin data do |pin|
          pin.should eq pin_code
        end if done?

        # UserName
        builder.create_name(data, _id_) do |done?, name|
          name.should eq _def[ti][:nameWithEmail][:name] if done?
        end if done?

        # EmailAddress
        builder.create_email(data, _id_) do |done?, email|
          email.should eq _def[ti][:nameWithEmail][:email] if done?
        end if done?
      end
    end
  end
end
