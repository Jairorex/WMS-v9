<?php

namespace App\Traits;

trait ApiResponse
{
    /**
     * Respuesta exitosa estandarizada
     */
    protected function successResponse($data = null, $message = null, $statusCode = 200)
    {
        $response = [
            'success' => true,
        ];

        if ($message) {
            $response['message'] = $message;
        }

        if ($data !== null) {
            $response['data'] = $data;
        }

        return response()->json($response, $statusCode);
    }

    /**
     * Respuesta de error estandarizada
     */
    protected function errorResponse($message = 'Error en la operación', $errors = null, $statusCode = 400)
    {
        $response = [
            'success' => false,
            'message' => $message,
        ];

        if ($errors) {
            $response['errors'] = $errors;
        }

        return response()->json($response, $statusCode);
    }

    /**
     * Respuesta con datos paginados
     */
    protected function paginatedResponse($data, $message = null)
    {
        $response = [
            'success' => true,
            'data' => $data->items(),
            'meta' => [
                'total' => $data->total(),
                'per_page' => $data->perPage(),
                'current_page' => $data->currentPage(),
                'last_page' => $data->lastPage(),
                'from' => $data->firstItem(),
                'to' => $data->lastItem(),
            ],
        ];

        if ($message) {
            $response['message'] = $message;
        }

        return response()->json($response);
    }
}

