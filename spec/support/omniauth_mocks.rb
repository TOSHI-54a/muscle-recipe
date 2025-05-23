module OmniauthMocks
    def mock_auth_hash(provider = :google)
        OmniAuth.config.mock_auth[provider] = OmniAuth::AuthHash.new({
            provider: provider.to_s,
            uid: '12345',
            info: {
                email: "test@example.com",
                name: "Test User"
            },
            credentials: {
                token: "mock_token",
                expires_at: Time.now + 1.week
            }
        })
    end

    def mock_invalid_auth(provider = :google)
        OmniAuth.config.mock_auth[provider] = :invalid_credentials
    end
end
