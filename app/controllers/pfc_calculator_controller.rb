class PfcCalculatorController < ApplicationController
  def create
    data = pfc_params
    result = PfcCalculator.calculate(
      age: data[:age].to_i,
      height: data[:height].to_f,
      weight: data[:weight].to_f,
      gender: data[:gender],
      activity_level: data[:activity_level].to_f
    )

    render partial: "pfc_result", locals: { pfc_data: result }
  end

  private

  def pfc_params
    params.permit(:age, :height, :weight, :gender, :activity_level)
  end
end
