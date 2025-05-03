require 'rails_helper'

RSpec.describe User, type: :model do
  it "is valid with a name, email, and age" do
    user = build(:user)
    expect(user).to be_valid
  end

  it "is invalid without a name" do
    user = build(:user, name: nil)
    expect(user).not_to be_valid
    expect(user.errors.full_messages).to include("名前を入力してください")
  end

  it "メールアドレスが入力されているか" do
    user = build(:user, email: nil)
    expect(user).not_to be_valid
    expect(user.errors.full_messages).to include("メールアドレスを入力してください")
  end

  it "メールアドレスがユニークか" do
    create(:user, email: "test@example.com")
    user = build(:user, email: "test@example.com")
    expect(user).not_to be_valid
    expect(user.errors.full_messages).to include("メールアドレスはすでに存在します")
  end

  it "メールアドレスが有効な形式か" do
    user = build(:user, email: "test")
    expect(user).not_to be_valid
    expect(user.errors.full_messages).to include("メールアドレスは有効な形式で入力してください")
  end

  it "性別が有効な値であること" do
    user = User.new(name: "Test User", email: "test@example.com", password: "password", gender: "male")
    expect(user).to be_valid
  end

  it "性別が無効な値である場合、無効であること" do
    user = User.new(name: "Test User", email: "test@example.com", password: "password", gender: "invalid")
    expect(user).not_to be_valid
  end
end
