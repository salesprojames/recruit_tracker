class ToPhoneNumber
	def convert(number)
		return "+1" + number.sub('+1', '').tr("^0-9", '')
	end
end