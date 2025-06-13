class PfcCalculator
    def self.calculate(age:, height:, weight:, gender:, activity_level:)
        sex_const = gender == "male" ? 0.4235 : 0.9708
        bmr_kj = 0.1238 + (0.0481 * weight) + (0.0234 * height) - (0.0138 * age) - sex_const
        bmr = (bmr_kj * 1000) / 4.186
        tdee = bmr * activity_level

        {
            bmr: bmr.round,
            tdee: tdee.round,
            p: (tdee * 0.20 / 4).round,
            f: (tdee * 0.30 / 9).round,
            c: (tdee * 0.50 / 4).round
        }
    end
end
