#include "ModelAnimation.as"
#include "Utilities.as"

shared class PhysicalActorRunAnim : ModelAnimation
{
	private PhysicalActor@ actor;
	private ActorModel@ model;

	private float maxHeadAngle = 60.0f;

	PhysicalActorRunAnim(PhysicalActor@ actor, ActorModel@ model)
	{
		@this.actor = actor;
		@this.model = model;
	}

	void Animate(float t)
	{
		Vec2f a = actor.interRotation.dir().toXZ();
		Vec2f b = actor.interVelocity.toXZ() * 3.0f;
		float bodyAngle = b.LengthSquared() > 0 ? Maths::Clamp(Vec2f_cross(a, b) * 90, -45, 45) : 0;

		float rt = t * Maths::Pi * 2.0f;

		Vec2f velXZ = actor.interVelocity.toXZ();
		float vel = velXZ.Length() * 5.0f;

		float sin = Maths::Sin(rt) * vel;
		float cos = Maths::Cos(rt) * vel;

		float limbSin = sin * 40.0f;
		float limbCos = cos * 40.0f;

		model.body.offset = Vec3f(0, Maths::Abs(cos * 0.1f) * vel * 1.5f, 0) + actor.interPosition;
		model.body.rotation = Vec3f(-4.0f * vel + Maths::Sin(rt * 2.0f) * vel * -4.0f, 0, cos);
		model.body.rotation.y = actor.interRotation.y + bodyAngle;

		model.head.rotation = actor.interRotation + Vec3f(Maths::Sin(rt * 2.0f) * vel * 4.0f, -model.body.rotation.y, 0);

		model.upperLeftArm.rotation = Vec3f(-limbCos, 0, 0);
		model.upperRightArm.rotation = Vec3f(limbCos, 0, 0);

		model.lowerLeftArm.rotation = Vec3f(Maths::Max(0, -limbCos), 0, 0);
		model.lowerRightArm.rotation = Vec3f(Maths::Max(0, limbCos), 0, 0);

		model.upperLeftLeg.rotation = Vec3f(limbCos, 0, 0);
		model.upperRightLeg.rotation = Vec3f(-limbCos, 0, 0);

		model.lowerLeftLeg.rotation = Vec3f(Maths::Min(0, limbSin), 0, 0);
		model.lowerRightLeg.rotation = Vec3f(Maths::Min(0, -limbSin), 0, 0);
	}
}
