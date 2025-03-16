<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\AuthController;
use App\Http\Controllers\CategoryController;
use App\Http\Controllers\LabelController;
use App\Http\Controllers\TodoController;

Route::get('/user', [AuthController::class, 'user']);
Route::post('/register', [AuthController::class, 'register']);
Route::post('/login', [AuthController::class, 'login']);

// Rute yang memerlukan autentikasi dengan Sanctum
Route::prefix('services')->middleware('auth:sanctum')->group(function () {
    Route::post('/logout', [AuthController::class, 'logout']);
    Route::apiResource('todos', TodoController::class);

    Route::apiResource('categories', CategoryController::class);
    Route::apiResource('labels', LabelController::class);
});
