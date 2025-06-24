require 'rails_helper'

RSpec.describe 'PfcCalculator', type: :request do
    let(:user) { create(:user) }
    describe 'POST /pfc_calculator' do
        it 'PFC計算結果が返る' do
            sign_in user
            age = 30
            height = 170
            weight = 65
            gender = 'male'
            activity_level = 1.55

            post pfc_calculator_path, params: {
                age: age,
                height: height,
                weight: weight,
                gender: gender,
                activity_level: activity_level
            }, headers: { "Turbo-Frame" => "pfc_result_frame" }

            bmr_kj = 0.1238 + (0.0481 * weight) + (0.0234 * height) - (0.0138 * age) - 0.4235
            bmr = (bmr_kj * 1000) / 4.186
            formatted_bmr = bmr.round.to_s

            expect(response.body).to include('<turbo-frame id="pfc_result">')
            expect(response.body).to include("推定エネルギー必要量")
            expect(response.body).to include("#{formatted_bmr} kcal")
        end
    end
end
