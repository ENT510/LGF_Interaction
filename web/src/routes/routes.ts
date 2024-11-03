// routes.js

import { IconCar, IconTools, IconDashboard } from "@tabler/icons-react";
import GarageManagement from "../components/garage/Upgrades";
import Garage from "../components/garage/Garage";
import GarageOwnerPage from "../components/garage/OwnerManagement";

export const routes = [
    {
        path: "/",
        label: "Vehicles",
        icon: IconCar,
        subRoutes: [
            {
                path: "/current_garage_vehicles",
                label: "Current Garage",
                icon: IconDashboard,
                element: Garage,
            },
            {
                path: "/all_garages_vehicles",
                label: "All Garages",
                icon: IconTools,
                element: Garage,
            },
        ],
    },
    {
        path: "/garage_upgrades",
        label: "Garage Enhancements",
        icon: IconTools,
        subRoutes: [
            {
                path: "/manage_current_garage",
                label: "Garage Info",
                icon: IconDashboard,
                element: GarageManagement,
            },
            {
                path: "/owner_manage_current_garage",
                label: "Manage Garage",
                icon: IconTools,
                element: GarageOwnerPage,
            },
        ],
    },
];
