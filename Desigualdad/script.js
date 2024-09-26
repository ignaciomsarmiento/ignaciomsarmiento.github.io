// Función para actualizar el valor del slider en pantalla
function actualizarValor(valor) {
    document.getElementById("ingresoValor").innerText = valor;
}

// Función para mostrar la pregunta de clase social
function preguntarClase() {
    document.getElementById("preguntaClase").style.display = "block";
}


function mostrarGrafica(claseSocial) {
    // Obtener el ingreso seleccionado por el usuario
    var ingresoUsuario = parseFloat(document.getElementById("ingresoSlider").value);

    // Datos de distribución de ingresos (en millones de COP)
    var ingresos = Array.from({length: 61}, (_, i) => i * 0.5); // De 0 a 30 en pasos de 0.5
    var frecuencias = ingresos.map(ingreso => Math.exp(-0.1 * (ingreso - 15) ** 2)); // Distribución ficticia

    // Normalizar las frecuencias para que sumen 1
    var totalFrecuencia = frecuencias.reduce((a, b) => a + b, 0);
    frecuencias = frecuencias.map(f => f / totalFrecuencia);

    // Calcular el porcentaje de individuos con ingreso menor al del usuario
    var porcentaje = calcularPorcentaje(ingresoUsuario, ingresos, frecuencias);

    // Mostrar el contenedor de la gráfica
    document.getElementById("graficaContainer").style.display = "block";

    // Crear la gráfica con Chart.js
    var ctx = document.getElementById("graficaIngresos").getContext("2d");
    
    // Limpiar la gráfica si ya existe
    if (window.grafica) {
        window.grafica.destroy();
    }

    // Obtener el índice del ingreso seleccionado
    var indexIngreso = Math.round(ingresoUsuario * 2); // Multiplicamos por 2 porque los pasos del slider son de 0.5
    var densidadUsuario = frecuencias[indexIngreso];

    window.grafica = new Chart(ctx, {
        type: 'line',
        data: {
            labels: ingresos.map(v => `${v.toFixed(1)}M`),
            datasets: [{
                label: 'Distribución de Ingresos (millones COP)',
                data: frecuencias,
                borderColor: 'rgba(54, 162, 235, 1)',
                borderWidth: 2,
                fill: true,
                backgroundColor: 'rgba(255, 255, 255, 0)', // Fondo blanco
            }, {
                label: 'Área hasta el ingreso del usuario',
                data: ingresos.map((_, i) => (ingresos[i] <= ingresoUsuario ? frecuencias[i] : null)),
                borderColor: 'rgba(255, 99, 132, 0)', // Sin borde visible
                backgroundColor: 'rgba(255, 99, 132, 0.5)', // Color de la sombra
                fill: true
            }]
        },
        options: {
            scales: {
                x: {
                    beginAtZero: true
                },
                y: {
                    beginAtZero: true,
                    title: {
                        display: true,
                        text: 'Densidad'
                    }
                }
            },
            plugins: {
                annotation: {
                    annotations: {
                        lineaUsuario: {
                            type: 'line',
                            xMin: indexIngreso,
                            xMax: indexIngreso,
                            borderColor: 'red', // Color de la línea en rojo
                            borderWidth: 2,
                            label: {
                                content: `Tu ingreso: ${ingresoUsuario}M`,
                                enabled: true,
                                position: 'top'
                            }
                        }
                    }
                }
            }
        }
    });

    // Actualizar el texto que muestra el porcentaje
    document.getElementById("porcentajeMenor").innerText = `El ${porcentaje.toFixed(1)}% gana menos que usted`;

    // Mostrar el porcentaje en la consola para depuración
    console.log(`Porcentaje de individuos con ingreso menor a ${ingresoUsuario}M: ${porcentaje.toFixed(1)}%`);
}








// Función para calcular el porcentaje relativo del ingreso
function calcularPorcentaje(ingreso, ingresos, frecuencias) {
    var totalFrecuencia = frecuencias.reduce((a, b) => a + b, 0);
    var frecuenciaAcumulada = 0;

    for (var i = 0; i < ingresos.length; i++) {
        if (ingreso < ingresos[i]) break;
        frecuenciaAcumulada += frecuencias[i];
    }

    return (frecuenciaAcumulada / totalFrecuencia) * 100;
}
