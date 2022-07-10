<?php

namespace App\Controller;

use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\HttpFoundation\JsonResponse;
use Symfony\Component\Routing\Annotation\Route;

class DebugController extends AbstractController
{
    /**
     * @Route("/debug", name="debug")
     */
    public function index(): JsonResponse
    {
        $copied_server = [];

        foreach ($_SERVER as $key => $value) {
            if ($key === 'AWS_SESSION_TOKEN' || $key === 'AWS_ACCESS_KEY_ID' || $key === 'AWS_SECRET_ACCESS_KEY') {
                continue;
            }
            $copied_server[$key] = $value;
        }

        return $this->json([
            'data' => $copied_server,
            'message' => 'Welcome to your new controller!',
            'path' => 'src/Controller/DebugController.php',
        ]);
    }
}
