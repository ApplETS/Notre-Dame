package ca.etsmtl.applets.etsmobile.services.models

data class ApiError(override val message: String) : Exception(message)