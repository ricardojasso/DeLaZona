const { onDocumentCreated, onDocumentUpdated } = require("firebase-functions/v2/firestore");
const admin = require("firebase-admin");

if (!admin.apps.length) {
    admin.initializeApp();
}

// ============================================================================
// ROBOT 1: Notifica al Restaurante cuando tiene un nuevo seguidor (¡GATILLO INSTANTÁNEO!)
// ============================================================================
// Ahora vigila directamente si cambió la lista de seguidores del restaurante
exports.enviarNotificacionNuevoSeguidor = onDocumentUpdated("restaurantes/{restauranteId}", async (event) => {
  const antes = event.data.before.data();
  const despues = event.data.after.data();

  const seguidoresAntes = antes.seguidores || [];
  const seguidoresDespues = despues.seguidores || [];

  // Si la lista de seguidores es igual, o si alguien dejó de seguir, no hacemos nada
  if (seguidoresDespues.length <= seguidoresAntes.length) {
      return null;
  }

  console.log(`🚀 [ROBOT 1] ¡Nuevo seguidor detectado al instante en restaurante: ${event.params.restauranteId}!`);

  const titulo = "¡Nuevo Seguidor! 🎉";
  const mensaje = "Alguien nuevo ha comenzado a seguir tu restaurante.";

  try {
    const token = despues.fcmToken || despues.fcm_token;
    if (!token) {
        console.log("🛑 [ROBOT 1] El restaurante no tiene token guardado.");
        return null;
    }

    const message = {
      notification: { title: titulo, body: mensaje },
      // 🔥 NUEVO: Enviamos título y mensaje también en 'data' para forzar el despertar
      data: { 
          click_action: "FLUTTER_NOTIFICATION_CLICK", 
          tipo: "seguidor", 
          restauranteId: event.params.restauranteId,
          title: titulo,
          body: mensaje
      },
      android: { priority: "high", notification: { sound: "default" } },
      apns: { payload: { aps: { sound: "default" } } },
      token: token,
    };

    await admin.messaging().send(message);
    console.log("✅ [ROBOT 1] Notificación de seguidor enviada con éxito.");
    return null;
  } catch (error) {
    console.error("🚨 [ROBOT 1] Error:", error);
    return null;
  }
});

// ============================================================================
// ROBOT 2: Notifica a los Clientes cuando el restaurante abre o cierra
// ============================================================================
exports.notificarCambioEstadoRestaurante = onDocumentUpdated("restaurantes/{restauranteId}", async (event) => {
  const antes = event.data.before.data();
  const despues = event.data.after.data();

  const estabaAbiertoAntes = antes.is_abierto;
  const estaAbiertoAhora = despues.is_abierto;

  if (estabaAbiertoAntes === estaAbiertoAhora) return null; 

  const nombreRestaurante = despues.nombre_restaurante || despues.nombre || "Tu restaurante favorito";
  const seguidores = despues.seguidores || [];

  if (seguidores.length === 0) return null;

  const titulo = estaAbiertoAhora 
      ? `¡${nombreRestaurante} ya está abierto! 🟢` 
      : `${nombreRestaurante} ha cerrado 🔴`;
      
  const cuerpo = estaAbiertoAhora
      ? `Acaba de abrir. ¡Haz tu pedido antes de que se acabe!`
      : `Te esperamos mañana. ¡Gracias por tu preferencia!`;

  try {
    const tokens = [];
    const promesasClientes = seguidores.map(uid => admin.firestore().collection("clientes").doc(uid).get());
    const snapshotsClientes = await Promise.all(promesasClientes);

    snapshotsClientes.forEach((doc) => {
      if (doc.exists) {
        const tokenCliente = doc.data().fcmToken || doc.data().fcm_token;
        if (tokenCliente) tokens.push(tokenCliente);
      }
    });

    if (tokens.length === 0) return null;

    const message = {
      notification: { title: titulo, body: cuerpo },
      // 🔥 NUEVO: Wake-up data
      data: { 
          click_action: "FLUTTER_NOTIFICATION_CLICK", 
          tipo: "estado_restaurante", 
          restauranteId: event.params.restauranteId,
          title: titulo,
          body: cuerpo
      },
      android: { priority: "high", notification: { sound: "default" } },
      apns: { payload: { aps: { sound: "default" } } },
      tokens: tokens,
    };

    await admin.messaging().sendEachForMulticast(message);
    return null;
  } catch (error) {
    console.error("💥 [ROBOT 2] Error:", error);
    return null;
  }
});

// ============================================================================
// ROBOT 3: Notifica a los Clientes cuando hay un NUEVO PLATILLO 🌮🍕
// ============================================================================
exports.notificarNuevoPlatillo = onDocumentCreated("platillos/{platilloId}", async (event) => {
  const snapshot = event.data;
  if (!snapshot) return null;

  const datosPlatillo = snapshot.data();
  const restauranteId = datosPlatillo.restauranteId || datosPlatillo.id_restaurante; 
  const nombrePlatillo = datosPlatillo.nombre || datosPlatillo.name || "un platillo delicioso"; 

  if (!restauranteId) return null;

  try {
    const restauranteDoc = await admin.firestore().collection("restaurantes").doc(restauranteId).get();
    if (!restauranteDoc.exists) return null;

    const restauranteData = restauranteDoc.data();
    const nombreRestaurante = restauranteData.nombre_restaurante || restauranteData.nombre || "Tu restaurante favorito";
    const seguidores = restauranteData.seguidores || [];

    if (seguidores.length === 0) return null;

    const titulo = `🍽️ ¡Nuevo en ${nombreRestaurante}!`;
    const cuerpo = `Acaban de agregar: ${nombrePlatillo}. ¡Pruébalo ahora!`;

    const tokens = [];
    const promesasClientes = seguidores.map(uid => admin.firestore().collection("clientes").doc(uid).get());
    const snapshotsClientes = await Promise.all(promesasClientes);

    snapshotsClientes.forEach((doc) => {
      if (doc.exists) {
        const tokenCliente = doc.data().fcmToken || doc.data().fcm_token;
        if (tokenCliente) tokens.push(tokenCliente);
      }
    });

    if (tokens.length === 0) return null;

    const message = {
      notification: { title: titulo, body: cuerpo },
      // 🔥 NUEVO: Wake-up data
      data: { 
          click_action: "FLUTTER_NOTIFICATION_CLICK", 
          tipo: "nuevo_platillo", 
          restauranteId: restauranteId,
          title: titulo,
          body: cuerpo
      },
      android: { priority: "high", notification: { sound: "default" } },
      apns: { payload: { aps: { sound: "default" } } },
      tokens: tokens,
    };

    await admin.messaging().sendEachForMulticast(message);
    return null;
  } catch (error) {
    console.error("🚨 [ROBOT 3] Error:", error);
    return null;
  }
});

// ============================================================================
// ROBOT 4: Notifica a los Clientes sobre una NUEVA PROMOCIÓN 💸🔥
// ============================================================================
exports.notificarNuevaPromocion = onDocumentUpdated("restaurantes/{restauranteId}", async (event) => {
  const antes = event.data.before.data();
  const despues = event.data.after.data();

  const promoAntes = antes.promocion || "";
  const promoDespues = despues.promocion || "";

  if (promoAntes === promoDespues || promoDespues.trim() === "") return null; 

  const nombreRestaurante = despues.nombre_restaurante || "Tu restaurante favorito";
  const descripcionPromo = despues.promocion_descripcion || "";
  const seguidores = despues.seguidores || [];

  if (seguidores.length === 0) return null;

  try {
    const tituloPush = `🔥 ¡Oferta en ${nombreRestaurante}!`;
    const cuerpoPush = descripcionPromo.trim() !== "" 
        ? `${promoDespues} - ${descripcionPromo}` 
        : `¡Aprovecha: ${promoDespues}!`;

    const tokens = [];
    const promesasClientes = seguidores.map(uid => admin.firestore().collection("clientes").doc(uid).get());
    const snapshotsClientes = await Promise.all(promesasClientes);

    snapshotsClientes.forEach((doc) => {
      if (doc.exists) {
        const tokenCliente = doc.data().fcmToken || doc.data().fcm_token;
        if (tokenCliente) tokens.push(tokenCliente);
      }
    });

    if (tokens.length === 0) return null;

    const message = {
      notification: { title: tituloPush, body: cuerpoPush },
      // 🔥 NUEVO: Wake-up data
      data: { 
          click_action: "FLUTTER_NOTIFICATION_CLICK", 
          tipo: "nueva_promocion", 
          restauranteId: event.params.restauranteId,
          title: tituloPush,
          body: cuerpoPush
      },
      android: { priority: "high", notification: { sound: "default" } },
      apns: { payload: { aps: { sound: "default" } } },
      tokens: tokens,
    };

    await admin.messaging().sendEachForMulticast(message);
    return null;
  } catch (error) {
    console.error("🚨 [ROBOT 4] Error al notificar promoción:", error);
    return null;
  }
});