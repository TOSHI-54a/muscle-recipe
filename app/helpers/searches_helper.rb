module SearchesHelper
    def tab_class(name)
        base = "py-2 px-4 border-b-2"
        active = "border-blue-500 font-semibold"
        inactive = "border-transparent text-gray-500 hover:text-blue-500"

        params[:tab] == name ? "#{base} #{active}" : "#{base} #{inactive}"
    end
end
