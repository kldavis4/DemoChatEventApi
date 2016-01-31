# Be sure to restart your server when you modify this file.

# Your secret key is used for verifying the integrity of signed cookies.
# If you change this key, all old signed cookies will become invalid!

# Make sure the secret is at least 30 characters and all random,
# no regular words or you'll be exposed to dictionary attacks.
# You can use `rake secret` to generate a secure secret key.

# Make sure your secret_key_base is kept private
# if you're sharing your code publicly.
EventApi::Application.config.secret_key_base = '50f80908d3124a0172c4a898a4f01f504741e2760a9be79a27f825b01ec0977ff0b8637704cb97b8bec94ead26cf9947923005ddf519475be561b42b96eda2f7'
